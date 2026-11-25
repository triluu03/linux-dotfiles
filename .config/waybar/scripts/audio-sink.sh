#!/usr/bin/env bash
set -euo pipefail

# Sink picker: list PipeWire audio sinks and set the chosen one as default.
ids=()
labels=()
while IFS= read -r line; do
  default=0
  if [[ "$line" == \** ]]; then
    default=1
    line="${line#\*}"
    line="${line# }"
  fi
  ids+=("${line%%.*}")
  if (( default )); then
    labels+=("● ${line#*. }")
  else
    labels+=("  ${line#*. }")
  fi
done < <(wpctl status |
  sed -n '/Sinks:/,/Sources:/p' |
  grep -E '^\s*│\s+[0-9*]' |
  sed -E 's/^\s*│\s+//; s/\[vol:.*//; s/[[:space:]]+/ /g; s/^ //; s/ $//' || true)

if (( ${#ids[@]} == 0 )); then
  notify-send "No audio sinks found"
  exit 1
fi

sel="$(printf '%s\n' "${labels[@]}" | rofi -dmenu -i -format i -p "Output")"
[[ -z "$sel" ]] && exit 0
if [[ ! "$sel" =~ ^[0-9]+$ ]] || (( sel < 0 || sel >= ${#ids[@]} )); then
  exit 0
fi
wpctl set-default "${ids[$sel]}"
