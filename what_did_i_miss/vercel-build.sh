#!/usr/bin/env bash
set -euo pipefail

git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter
export PATH="$PATH:$PWD/_flutter/bin"

flutter config --no-analytics
flutter pub get
flutter build web --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="${SUPABASE_PUBLISHABLE_KEY}"