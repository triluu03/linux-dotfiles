#!/usr/bin/env bash
# Waybar custom module: ethernet status.
# Mirrors the i3status "ethernet _first_" block: "E: <link speed>" / "E: down".
# Emits JSON for waybar's "return-type": "json".

set -u

iface="${1:-enp2s0}"
icon=$'\uf0ac'

operstate="down"
speed=""

[[ -r "/sys/class/net/$iface/operstate" ]] && operstate=$(<"/sys/class/net/$iface/operstate")
[[ -r "/sys/class/net/$iface/speed" ]] && speed=$(<"/sys/class/net/$iface/speed")

if [[ "$operstate" == "up" && -n "$speed" && "$speed" != "-1" ]]; then
  text="$icon E: ${speed} Mbit/s"
  class="up"
  tooltip="Ethernet ($iface): ${speed} Mbit/s"
else
  text="$icon E: down"
  class="down"
  tooltip="Ethernet ($iface): down"
fi

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$class" "$tooltip"
