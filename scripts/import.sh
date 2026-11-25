#!/usr/bin/env bash
# Load a database dump from another site and point it at this stack.
# Usage: scripts/import.sh path/to/dump.sql[.gz] [old-site-url]
# It empties the local database first. Give the old URL only if the script cannot read it from the dump.
set -euo pipefail
dump=${1:?Usage: scripts/import.sh path/to/dump.sql[.gz] [old-site-url]}
[ -f "$dump" ] || { echo "No such file: $dump" >&2; exit 1; }
dump=$(cd "$(dirname "$dump")" && pwd)/$(basename "$dump")
cd "$(dirname "$0")/.."
if [ -f .env ]; then set -a; . ./.env; set +a; fi
url=${WP_URL:-http://localhost:${WP_PORT:-8080}}

wp() { docker compose run --rm -T cli "$@"; }

docker compose up -d --wait db wordpress mailpit

# Start from an empty database, so no table from an earlier site is left behind.
wp db reset --yes

case "$dump" in
  *.gz) gunzip -c "$dump" ;;
  *) cat "$dump" ;;
esac | wp db import -

if ! wp core is-installed >/dev/null 2>&1; then
  echo "Imported, but WordPress cannot find its tables with the prefix '${WP_TABLE_PREFIX:-wp_}'." >&2
  echo "Tables that look like an options table:" >&2
  wp db query "SHOW TABLES LIKE '%options'" --skip-column-names >&2 || true
  echo "Set WP_TABLE_PREFIX in .env to match, then run this script again." >&2
  exit 1
fi

old=${2:-$(wp option get siteurl | tr -d '\r')}
if [ "$old" != "$url" ]; then
  wp search-replace "$old" "$url" --all-tables --skip-columns=guid --report-changed-only
fi
wp rewrite flush
wp cache flush

printf '\nImported %s\nSite: %s (was %s)\nThe admin users are the ones in the dump. To set a password:\n  docker compose run --rm cli user update <login> --user_pass=<new password>\n' \
  "$(basename "$dump")" "$url" "$old"
