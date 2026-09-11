#!/usr/bin/env sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKEND="$ROOT/../GoldenLook-Backend/contracts/colors.json"
FRONTEND="$ROOT/../GoldenLook-Frontend/lib/generated/colors.json"
INTEGRATION="$ROOT/contracts/colors.json"

cmp "$BACKEND" "$FRONTEND"
cmp "$BACKEND" "$INTEGRATION"
shasum -a 256 "$BACKEND" "$FRONTEND" "$INTEGRATION"
