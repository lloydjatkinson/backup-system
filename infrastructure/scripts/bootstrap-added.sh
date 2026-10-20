#!/usr/bin/env bash
# Init a restic repo for each destination of every machine added in this change.
set -euo pipefail

if git rev-parse HEAD^ >/dev/null 2>&1; then
  added=$(comm -13 \
    <(git show "HEAD^:infrastructure/machines.json" 2>/dev/null | jq -r '.machines[]' | sort) \
    <(jq -r '.machines[]' machines.json | sort))
else
  added=$(jq -r '.machines[]' machines.json | sort)
fi
[[ -n "$added" ]] || { echo "No machines added; nothing to do."; exit 0; }

repos="$(tofu output -json repositories)"

while IFS= read -r machine; do
  [[ -n "$machine" ]] || continue
  entry="$(jq -c --arg m "$machine" '.[$m]' <<<"$repos")"
  [[ "$entry" != null ]] || { echo "::error::no output entry for $machine"; exit 1; }

  password="$(jq -r '.password' <<<"$entry")"
  echo "::add-mask::$password"

  for dest in $(jq -r '.destinations | keys[]' <<<"$entry"); do
    echo "::group::$machine/$dest"
    d="$(jq -c --arg d "$dest" '.destinations[$d]' <<<"$entry")"

    repo_env=()
    while IFS='=' read -r name value; do
      echo "::add-mask::$value"
      repo_env+=("$name=$value")
    done < <(jq -r '.env | to_entries[] | "\(.key)=\(.value)"' <<<"$d")
    repo_env+=("RESTIC_PASSWORD=$password")
    repo_env+=("RESTIC_REPOSITORY=$(jq -r '.repository' <<<"$d")")

    if env "${repo_env[@]}" restic cat config >/dev/null 2>&1; then
      echo "::error::$machine/$dest added but a repo already exists; investigate"
      exit 1
    fi
    env "${repo_env[@]}" restic init
    env "${repo_env[@]}" restic snapshots --json --latest 1 >/dev/null
    echo "$machine/$dest: created"
    echo "::endgroup::"
  done
done <<< "$added"