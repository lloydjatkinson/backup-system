#!/usr/bin/env bash
# Recreate ONE repo after the check has flagged it missing and you've confirmed
# it's genuinely gone. The remade repo is EMPTY; old snapshots are not recovered.
# Run from infrastructure/. Needs tofu, restic and bash on PATH.
#
# Usage: ./recreate-repo.sh lloyd-desktop/b2
set -euo pipefail

key="${1:?usage: recreate-repo.sh <machine>/<destination>, e.g. lloyd-desktop/b2}"

tofu apply -replace="terraform_data.restic_init[\"${key}\"]"