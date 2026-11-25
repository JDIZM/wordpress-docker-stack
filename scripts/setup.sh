#!/usr/bin/env bash
# Start the stack and install WordPress if it is not installed yet. Safe to run again.
set -euo pipefail
cd "$(dirname "$0")/.."
if [ -f .env ]; then set -a; . ./.env; set +a; fi
url=${WP_URL:-http://localhost:${WP_PORT:-8080}}

wp() { docker compose run --rm cli "$@"; }

docker compose up -d --wait db wordpress mailpit
ready=0
for _ in {1..40}; do
  if wp core version >/dev/null 2>&1; then ready=1; break; fi
  sleep 2
done
if [ "$ready" != 1 ]; then
  echo "WordPress did not become ready. Look at: docker compose logs --tail=50 wordpress" >&2
  exit 1
fi

if ! wp core is-installed >/dev/null 2>&1; then
  wp core install --url="$url" --title="${WP_TITLE:-Local WordPress}" \
    --admin_user="${WP_ADMIN_USER:-admin}" --admin_password="${WP_ADMIN_PASSWORD:-password}" \
    --admin_email="${WP_ADMIN_EMAIL:-admin@example.test}" --skip-email
  wp rewrite structure '/%postname%/'
  # Only on a first install: an imported site keeps the theme and plugins its database names.
  wp theme activate "${THEME_SLUG:-starter-theme}"
  wp plugin activate "${PLUGIN_SLUG:-starter-plugin}"
fi

for plugin in ${WP_PLUGINS:-}; do wp plugin activate "$plugin"; done

printf '\nSite:  %s\nAdmin: %s/wp-admin/ (%s)\nMail:  http://localhost:%s\n' \
  "$url" "$url" "${WP_ADMIN_USER:-admin}" "${MAIL_PORT:-8025}"
