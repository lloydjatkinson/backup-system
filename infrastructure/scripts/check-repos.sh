#!/usr/bin/env bash
# Read-only. Confirms every repo exists in every destination.
# Run from infrastructure/. Needs tofu, restic and jq on PATH.
set -euo pipefail

repos="$(tofu output -json repositories)"
failed=()

while IFS= read -r row; do
  key="$(jq -r '.key' <<<"$row")"
  repo="$(jq -r '.repository' <<<"$row")"
  password="$(jq -r '.password' <<<"$row")"

  mapfile -t env_args < <(jq -r '.env | to_entries[] | "\(.key)=\(.value)"' <<<"$row")

  if env "${env_args[@]}" RESTIC_REPOSITORY="$repo" RESTIC_PASSWORD="$password" \
    restic cat config >/dev/null 2>&1; then
    echo "ok: $key"
  else
    echo "MISSING: $key"
    failed+=("$key")
  fi
done < <(jq -c '
  to_entries[] as $m
  | $m.value.destinations | to_entries[] as $d
  | {
      key: "\($m.key)/\($d.key)",
      repository: $d.value.repository,
      password: $m.value.password,
      env: $d.value.env
    }
' <<<"$repos")

if ((${#failed[@]})); then
  echo "FAILED: ${failed[*]}" >&2
  exit 1
fi
echo "all repos present"