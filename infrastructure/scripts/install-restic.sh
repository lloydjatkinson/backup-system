#!/usr/bin/env bash
# Install a pinned, checksum-verified restic and put it on PATH (GitHub Actions).
set -euo pipefail

version="0.19.1"
sha256="f415415624dcc452f2a02b8c33641791a8c6d6d3b65bbb3543fcf9a25151585c"
url="https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_amd64.bz2"

dir="$HOME/.local/bin"
mkdir -p "$dir"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

curl -fsSL --retry 5 --retry-all-errors --retry-delay 2 "$url" -o "$tmp/restic.bz2"
echo "${sha256}  ${tmp}/restic.bz2" | sha256sum -c -
bunzip2 -f "$tmp/restic.bz2"
cp "$tmp/restic" "$dir/restic"
chmod +x "$dir/restic"

if [[ -n "${GITHUB_PATH:-}" ]]; then
  echo "$dir" >>"$GITHUB_PATH"
fi

echo "installed $("$dir/restic" version)"