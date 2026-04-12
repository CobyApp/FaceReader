#!/bin/bash
# Reads repo-root .env and writes FaceReader/Configuration/Secrets.generated.xcconfig
# so Info.plist can keep using $(SUPABASE_*). Run via FaceReaderEnv aggregate target.

set -euo pipefail

ROOT="${SRCROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
ENV_FILE="${ROOT}/.env"
OUT="${ROOT}/FaceReader/Configuration/Secrets.generated.xcconfig"

mkdir -p "$(dirname "$OUT")"

write_placeholder() {
  echo "// Generated — create repo-root .env (copy from .env.example)" >"$OUT"
  echo "URL_SLASH = /" >>"$OUT"
  echo "SUPABASE_URL = " >>"$OUT"
  echo "SUPABASE_PUBLISHABLE_KEY = " >>"$OUT"
}

if [[ ! -f "$ENV_FILE" ]]; then
  write_placeholder
  exit 0
fi

# Read KEY=value (first match), strip optional surrounding quotes, trim leading space on key line
read_var() {
  local key="$1"
  local line
  line="$(grep -E "^[[:space:]]*${key}=" "$ENV_FILE" | tail -1 || true)"
  [[ -z "$line" ]] && { echo ""; return; }
  local val="${line#*=}"
  val="${val%$'\r'}"
  if [[ "$val" =~ ^\".*\"$ ]]; then
    val="${val#\"}"
    val="${val%\"}"
  elif [[ "$val" =~ ^\'.*\'$ ]]; then
    val="${val#\'}"
    val="${val%\'}"
  fi
  printf '%s' "$val"
}

URL_RAW="$(read_var SUPABASE_URL)"
KEY_RAW="$(read_var SUPABASE_PUBLISHABLE_KEY)"

# .xcconfig treats // as comment — avoid literal https:// in values
if [[ "$URL_RAW" == https://* ]]; then
  HOST="${URL_RAW#https://}"
  URL_OUT="https:\$(URL_SLASH)\$(URL_SLASH)${HOST}"
else
  URL_OUT="$URL_RAW"
fi

{
  echo "// Generated from .env — do not edit"
  echo "URL_SLASH = /"
  echo "SUPABASE_URL = ${URL_OUT}"
  echo "SUPABASE_PUBLISHABLE_KEY = ${KEY_RAW}"
} >"$OUT"
