#!/usr/bin/env bash
# Delete this stack's containers, database and WordPress core. Your wp-content folder stays.
set -euo pipefail
cd "$(dirname "$0")/.."
if [ "${1:-}" != "DELETE" ]; then
  echo 'Destructive: deletes the containers, the database volume and the WordPress core volume.'
  echo 'Themes, plugins and uploads in wp-content stay.'
  echo 'Run: bash scripts/reset.sh DELETE'
  exit 1
fi
docker compose --profile tools down --volumes
