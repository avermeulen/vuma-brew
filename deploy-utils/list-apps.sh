#!/bin/bash
set -e
[ -f /var/deploy-utils/.env ] && set -o allexport && source /var/deploy-utils/.env && set +o allexport
FILE="/var/deploy-utils/ports.json"
[ ! -f "$FILE" ] && echo "No apps deployed yet." && exit 0
echo "📋 Deployed apps:"
jq -r 'to_entries[] | "\(.key)\t\(.value)"' "$FILE" | while read APP PORT; do
  DOMAIN="${APP}.${BASE_DOMAIN}"
  STATUS=$(pm2 describe "$APP" >/dev/null 2>&1 && echo "🟢" || echo "🔴")
  printf "%-15s %-35s %-8s %-5s\n" "$APP" "$DOMAIN" "$PORT" "$STATUS"
done
