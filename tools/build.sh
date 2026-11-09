#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
engine="${GODOT_BIN:-godot}"
mkdir -p builds/web
run_check() {
  local log_file
  log_file="$(mktemp)"
  if ! "$@" 2>&1 | tee "$log_file"; then
    rm -f "$log_file"
    return 1
  fi
  if rg -q 'SCRIPT ERROR|ERROR:|Parse Error' "$log_file"; then
    rm -f "$log_file"
    return 1
  fi
  rm -f "$log_file"
}
python tools/verify_content.py
run_check "$engine" --headless --path game --editor --import --quit
run_check timeout 90 "$engine" --headless --path game --script res://tests/smoke.gd
run_check timeout 90 "$engine" --headless --path game --script res://tests/expansion.gd
run_check timeout 120 "$engine" --headless --path game --script res://tests/content.gd
run_check "$engine" --headless --path game --export-debug Android
if [[ "${BUILD_WEB:-1}" == "1" ]]; then
  run_check "$engine" --headless --path game --export-release Web
fi
