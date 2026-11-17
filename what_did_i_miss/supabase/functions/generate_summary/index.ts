import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "Content-Type, Authorization, apikey, x-client-info",
  "Access-Control-Max-Age": "86400",
};

type TopicSummary =
  | { topic: string; summary: string; status: number | null; responseBody: null }
  | {
      topic: string;
      error: string;
      status: number | null;
      responseBody: string | null;
    };

/** Normalize to YYYY-MM-DD (Linkup rejects datetimes / equal from+to). */
function toIsoDateOnly(raw: string): string | null {
  const m = raw.trim().match(/^(\d{4}-\d{2}-\d{2})/);
  return m ? m[1] : null;
}

function addDaysIso(isoDate: string, days: number): string {
  const [y, mo, d] = isoDate.split("-").map(Number);
  const dt = new Date(Date.UTC(y, mo - 1, d));
  dt.setUTCDate(dt.getUTCDate() + days);
  const yy = dt.getUTCFullYear();
  const mm = String(dt.getUTCMonth() + 1).padStart(2, "0");
  const dd = String(dt.getUTCDate()).padStart(2, "0");
  return `${yy}-${mm}-${dd}`;
}

/**
 * Linkup requires fromDate < toDate (strict).
 * Same-day product ranges → fromDate = day, toDate = next calendar day.
 */
function linkupDateParams(
  startDate: string,
  endDate: string,
): { fromDate: string; toDate: string } {
  let from = startDate;
  let to = endDate;
  if (from > to) {
    const tmp = from;
    from = to;
    to = tmp;
  }
  if (from === to) {
    to = addDaysIso(from, 1);
  }
  return { fromDate: from, toDate: to };
}

/**
 * Linkup sometimes embeds private-use citation tokens like:
 * \uE200cite\uE2023\uE201  (renders as weird glyphs in Flutter)
 */
function stripLinkupCitationMarkers(text: string): string {
  return text
    .replace(/\uE200cite\uE202\d+\uE201/g, "")
    .replace(/\uE200cite\uE202[^\uE201]*\uE201/g, "")
    .replace(/[ \t]+\n/g, "\n")
    .replace(/[ \t]{2,}/g, " ")
    .trim();
}

function formatLinkupError(status: number, statusText: string, text: string): string {
  let detail = `${status} - ${statusText}`;
  try {
    const errJson = JSON.parse(text) as {
      error?:
        | string
        | {
            message?: string;
            code?: string;
            details?: Array<{ field?: string; message?: string }>;
          };
      message?: string;
      details?: unknown;
    };
    const errObj = typeof errJson.error === "object" ? errJson.error : null;
    const msg =
      (typeof errJson.error === "string" ? errJson.error : errObj?.message) ??
      errJson.message;
    if (msg) detail = `${detail}: ${msg}`;
    if (errObj?.code) detail += ` [${errObj.code}]`;
    const nested = errObj?.details;
    if (Array.isArray(nested) && nested.length > 0) {
      const bits = nested.map((d) =>
        d.field ? `${d.field}: ${d.message ?? ""}` : (d.message ?? JSON.stringify(d)),
      );
      detail += ` — ${bits.join("; ")}`;
    } else if (errJson.details != null) {
      detail += ` (${JSON.stringify(errJson.details)})`;
    }
  } catch {
    // keep statusText-only detail
  }
  return `HTTP error: ${detail}`;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed. Use POST." }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const aiKey = Deno.env.get("AI_API_KEY");

  if (!supabaseUrl || !serviceKey) {
    return json({ error: "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY" }, 500);
  }
  if (!aiKey) {
    return json({ error: "Missing AI_API_KEY" }, 500);
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  const jwt = authHeader.replace(/^Bearer\s+/i, "").trim();
  if (!jwt) {
    return json({ error: "Missing Authorization Bearer token" }, 401);
  }

  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data: userData, error: userErr } = await admin.auth.getUser(jwt);
  if (userErr || !userData?.user) {
    return json({ error: "Invalid or expired session" }, 401);
  }
  const user = userData.user;

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON body" }, 400);
  }

  const topics = body["topics"];
  const startRaw = body["startDate"] as string | undefined;
  const endRaw = body["endDate"] as string | undefined;

  if (!topics || !Array.isArray(topics) || topics.length === 0) {
    return json({ error: "Missing or invalid topics array" }, 400);
  }
  if (!startRaw || !endRaw) {
    return json({ error: "Missing startDate or endDate" }, 400);
  }

  const startDate = toIsoDateOnly(String(startRaw));
  const endDate = toIsoDateOnly(String(endRaw));
  if (!startDate || !endDate) {
    return json(
      {
        error: "startDate and endDate must be YYYY-MM-DD",
        details: { startDate: startRaw, endDate: endRaw },
      },
      400,
    );
  }

  const topicStrings = topics
    .map((t) => String(t).trim())
    .filter((t) => t.length > 0);
  if (topicStrings.length === 0) {
    return json({ error: "No non-empty topics after trimming" }, 400);
  }

  const { data: inserted, error: insertErr } = await admin
    .from("summary_reports")
    .insert({
      user_id: user.id,
      date_start: startDate,
      date_end: endDate,
      topics: topicStrings,
      status: "processing",
    })
    .select("id")
    .single();

  if (insertErr || !inserted?.id) {
    console.error("insert error:", insertErr);
    return json(
      {
        error: "Failed to create report row",
        details: insertErr?.message ?? "unknown",
      },
      500,
    );
  }

  const reportId = inserted.id as string;
  const dateParams = linkupDateParams(startDate, endDate);
  const summaries: TopicSummary[] = [];

  for (const topic of topicStrings) {
    const query =
      `Important news in ${topic} from ${startDate} to ${endDate} IN MARKDOWN FORMAT. ` +
      "Remember to write at least two paragraphs and WRITE MORE IF THERE ARE MORE EVENTS. " +
      "Make sure to mention the date that it occurred when writing. " +
      "Use the largest header for the topic and date range at the top. " +
      "Use smaller headers with the topics and also bold those headers. " +
      "Remember to use all the features of markdown such as bolding, italics, " +
      "but minimize the use of line breaks or dividers to only the separation of topics. " +
      "Avoid biased sources like Fox News and MSNBC" +
      "Only use reputable sources (I. E. BBC, AP, NPR, Reuters, etc.) or official court documents.";

    let data: { answer?: string } | null = null;
    let fetchError: string | null = null;
    let status: number | null = null;
    let responseBody: string | null = null;

    try {
      const response = await fetch("https://api.linkup.so/v1/search", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${aiKey}`,
        },
        body: JSON.stringify({
          q: query,
          depth: "standard",
          outputType: "sourcedAnswer",
          includeInlineCitations: false,
          ...dateParams,
        }),
      });
      status = response.status;
      const text = await response.text();
      responseBody = text;
      try {
        data = JSON.parse(text) as { answer?: string };
      } catch (e) {
        fetchError = `Failed to parse response: ${(e as Error).message}`;
      }
      if (!response.ok) {
        fetchError = formatLinkupError(status, response.statusText, text);
        console.error("Linkup error:", topic, fetchError, text.slice(0, 800));
      }
    } catch (err) {
      fetchError = `Network or fetch error: ${(err as Error).message}`;
    }

    if (fetchError) {
      summaries.push({
        topic,
        error: fetchError,
        status,
        responseBody:
          responseBody && responseBody.length > 500
            ? responseBody.substring(0, 500) + "..."
            : responseBody,
      });
    } else {
      summaries.push({
        topic,
        summary: stripLinkupCitationMarkers(data?.answer ?? ""),
        status,
        responseBody: null,
      });
    }
  }

  let md = "";
  for (const entry of summaries) {
    if ("error" in entry) {
      md += `### Error for topic "${entry.topic}":\n\`\`\`\n${entry.error}\n\`\`\`\n\n---\n\n`;
    } else {
      md += `${entry.summary}\n\n---\n\n`;
    }
  }

  const anyError = summaries.some((s) => "error" in s);
  const finalStatus = anyError ? "completed_with_errors" : "completed";

  const { error: updateErr } = await admin
    .from("summary_reports")
    .update({
      status: finalStatus,
      result_markdown: md,
    })
    .eq("id", reportId)
    .eq("user_id", user.id);

  if (updateErr) {
    console.error("update error:", updateErr);
    await admin
      .from("summary_reports")
      .update({
        status: "failed",
        result_markdown: `### Save failed\n\`\`\`\n${updateErr.message}\n\`\`\``,
      })
      .eq("id", reportId)
      .eq("user_id", user.id);

    return json(
      {
        error: "Report generated but failed to save",
        details: updateErr.message,
        reportId,
        markdown: md,
      },
      500,
    );
  }

  return json(
    {
      reportId,
      status: finalStatus,
      markdown: md,
      debug: summaries,
    },
    200,
  );
});

function json(payload: unknown, status: number): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      ...corsHeaders,
    },
  });
}
