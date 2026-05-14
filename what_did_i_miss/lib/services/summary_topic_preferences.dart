import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/app_state.dart';

/// Persists summary topic picks in Supabase Auth [user.userMetadata] (per account).
class SummaryTopicPreferences {
  SummaryTopicPreferences._();

  static const metaSelected = 'summary_selected_topics';
  static const metaCustom = 'summary_custom_topic_labels';

  static List<String> stringListFromMeta(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Hydrates [appState] from the signed-in user's metadata (or clears if logged out).
  static void hydrateAppState(User? user, AppState appState) {
    if (user == null) {
      appState.hydrateSummaryTopics(const [], const []);
      return;
    }
    final m = user.userMetadata;
    appState.hydrateSummaryTopics(
      stringListFromMeta(m?[metaSelected]),
      stringListFromMeta(m?[metaCustom]),
    );
  }

  /// Writes lists to user metadata, merging with existing keys (e.g. [display_name]).
  static Future<void> persist(
    User? user,
    List<String> selectedTopics,
    List<String> customTopicLabels,
  ) async {
    if (user == null) return;
    final client = Supabase.instance.client;
    final current = client.auth.currentUser ?? user;
    final merged = Map<String, dynamic>.from(current.userMetadata ?? {});
    merged[metaSelected] = List<String>.from(selectedTopics);
    merged[metaCustom] = List<String>.from(customTopicLabels);
    await client.auth.updateUser(UserAttributes(data: merged));
  }
}
