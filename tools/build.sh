#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
engine="${GODOT_BIN:-godot}"
mkdir -p builds/web
"$engine" --headless --path game --editor --import --quit
timeout 40 "$engine" --headless --path game --script res://tests/smoke.gd
timeout 40 "$engine" --headless --path game --script res://tests/expansion.gd
"$engine" --headless --path game --export-debug Android
"$engine" --headless --path game --export-release Web
