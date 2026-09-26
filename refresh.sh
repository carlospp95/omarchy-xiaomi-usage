#!/bin/bash

# Lands the Xiaomi usage record where the agents panel watches.
# Mirrors omarchy-agent-usage-update: run the collector, sanity-check the
# JSON, then swap the file into place atomically so the panel never reads a
# half-written record.

plugin_dir="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"
usage_dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/agents/usage"

record=$(timeout 120 "$plugin_dir/omarchy-agent-usage-xiaomi") || exit 1
if [[ -z $record ]] || ! jq -e . >/dev/null 2>&1 <<<"$record"; then
  echo "xiaomi.agent-usage: collector emitted no valid JSON record" >&2
  exit 1
fi

mkdir -p "$usage_dir"
tmp=$(mktemp "$usage_dir/.xiaomi.XXXXXX")
if ! printf '%s\n' "$record" >"$tmp"; then
  rm -f "$tmp"
  exit 1
fi
mv "$tmp" "$usage_dir/xiaomi.json"

# The panel's brand mark resolves inside the built-in agents plugin
# (assets/xiaomi.svg), a directory plugin updates and omarchy upgrades can
# wipe. Reinstall whenever it goes missing; the directory is root-owned,
# so a read-only run degrades to a one-line hint instead of failing the
# refresh that already succeeded above.
assets_dir=/usr/share/omarchy/shell/plugins/agents/assets
if [[ -d $assets_dir && ( ! -e $assets_dir/xiaomi.svg || ! -e $assets_dir/xiaomi-light.svg ) ]]; then
  if install -m 644 "$plugin_dir/assets/xiaomi.svg" "$assets_dir/xiaomi.svg" 2>/dev/null &&
     install -m 644 "$plugin_dir/assets/xiaomi-light.svg" "$assets_dir/xiaomi-light.svg" 2>/dev/null; then
    echo "xiaomi.agent-usage: restored the Xiaomi panel mark in $assets_dir" >&2
  else
    echo "xiaomi.agent-usage: Xiaomi panel mark missing (optional). To restore it run:" >&2
    echo "  sudo install -m 644 $plugin_dir/assets/xiaomi.svg $assets_dir/xiaomi.svg" >&2
    echo "  sudo install -m 644 $plugin_dir/assets/xiaomi-light.svg $assets_dir/xiaomi-light.svg" >&2
  fi
fi
