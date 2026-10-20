#!/usr/bin/env bash
# Verify version + sha256 against https://github.com/restic/restic/releases before bumping.
set -euo pipefail

version=0.19.1
sha256=f415415624dcc452f2a02b8c33641791a8c6d6d3b65bbb3543fcf9a25151585c
archive="restic_${version}_linux_amd64.bz2"
root="${RUNNER_TEMP:-$(mktemp -d)}"
install_dir="$root/restic-bin"
mkdir -p "$install_dir"

curl --fail --location --silent --show-error --retry 3 \
  "https://github.com/restic/restic/releases/download/v${version}/${archive}" \
  --output "$root/$archive"
printf '%s  %s\n' "$sha256" "$root/$archive" | sha256sum --check
bzip2 -dc "$root/$archive" > "$install_dir/restic"
chmod 755 "$install_dir/restic"
"$install_dir/restic" version

[[ -n "${GITHUB_PATH:-}" ]] && echo "$install_dir" >> "$GITHUB_PATH"