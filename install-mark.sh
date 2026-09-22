#!/bin/bash

# Installs the Xiaomi brand mark where the built-in agents panel resolves it
# (assets/<id>.svg inside the omarchy agents plugin). The directory is
# root-owned, so this needs sudo. Both variants ship: the panel picks
# xiaomi.svg or xiaomi-light.svg per surface luminance. refresh.sh re-runs
# the plain (non-sudo) install whenever the mark goes missing and the
# directory happens to be writable; this script is the guaranteed path.

set -euo pipefail

plugin_dir="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"
assets_dir=/usr/share/omarchy/shell/plugins/agents/assets

[[ -d $assets_dir ]] || { echo "agents panel assets dir not found: $assets_dir" >&2; exit 1; }

install -m 644 "$plugin_dir/assets/xiaomi.svg" "$assets_dir/xiaomi.svg"
install -m 644 "$plugin_dir/assets/xiaomi-light.svg" "$assets_dir/xiaomi-light.svg"
echo "Installed the Xiaomi panel mark in $assets_dir; reopen the agents panel to see it."
