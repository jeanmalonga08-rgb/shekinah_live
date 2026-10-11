#!/usr/bin/env bash
# Bump version before flutter build appbundle (Mac / Linux).
# See scripts/bump_version_for_aab.py for the versioning policy.

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
python3 "$(dirname "$0")/bump_version_for_aab.py" "$@"
