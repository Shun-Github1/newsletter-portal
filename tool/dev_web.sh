#!/usr/bin/env bash
# Start Flutter web + local API proxy for development.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cleanup() {
  kill "$PROXY_PID" "$FLUTTER_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

python3 "$ROOT/tool/dev_api_proxy.py" &
PROXY_PID=$!

cd "$ROOT/app"
flutter run -d chrome --web-port=8080 --web-browser-flag "--disable-web-security" &
FLUTTER_PID=$!

wait "$FLUTTER_PID"
