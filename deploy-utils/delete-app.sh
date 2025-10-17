#!/bin/bash
set -e
APP_NAME=$1
[ -z "$APP_NAME" ] && echo "Usage: delete-app.sh <name>" && exit 1
[ -f /var/deploy-utils/.env ] && set -o allexport && source /var/deploy-utils/.env && set +o allexport
REPO="/var/repos/${APP_NAME}.git"
WWW="/var/www/${APP_NAME}"
CONF="/etc/nginx/sites-available/${APP_NAME}.conf"
pm2 stop "$APP_NAME" || true
pm2 delete "$APP_NAME" || true
rm -rf "$REPO" "$WWW"
rm -f "$CONF" "/etc/nginx/sites-enabled/${APP_NAME}.conf"
jq "del(.\"$APP_NAME\")" /var/deploy-utils/ports.json > tmp.$$.json && mv tmp.$$.json /var/deploy-utils/ports.json
systemctl reload nginx
echo "✅ Removed $APP_NAME"
