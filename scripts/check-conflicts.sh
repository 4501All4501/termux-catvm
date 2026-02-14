#!/usr/bin/env bash
set -euo pipefail

if rg -n "^(<<<<<<<|=======|>>>>>>>)" -S . >/tmp/catvm-conflicts.txt; then
  cat /tmp/catvm-conflicts.txt
  echo "Merge conflict markers found." >&2
  exit 1
fi

echo "No merge conflict markers found."
