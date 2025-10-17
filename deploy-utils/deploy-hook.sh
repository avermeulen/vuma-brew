#!/bin/bash
set -e
APP_NAME=$1; DOMAIN=$2; PORT=$3
[ -f /var/deploy-utils/.env ] && set -o allexport && source /var/deploy-utils/.env && set +o allexport
REPO_PATH="/var/repos/${APP_NAME}.git"
APP_PATH="/var/www/${APP_NAME}"
[ ! -d "$APP_PATH" ] && mkdir -p "$APP_PATH" && git clone "$REPO_PATH" "$APP_PATH"
cd "$APP_PATH"
git fetch origin && git reset --hard origin/main
npm ci --silent || npm install --silent
npm run build || true
pm2 start npm --name "$APP_NAME" -- run preview -- --port $PORT || pm2 restart "$APP_NAME"
pm2 save
CONF="/etc/nginx/sites-available/${APP_NAME}.conf"
cat <<EOCONF | sudo tee $CONF > /dev/null
server {
    listen 80;
    server_name $DOMAIN;
    location / {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
    }
}
EOCONF
ln -sf "$CONF" /etc/nginx/sites-enabled/
systemctl reload nginx
if [ "$USE_WILDCARD_SSL" != true ]; then
  certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$CERTBOT_EMAIL" || true
fi
systemctl reload nginx
echo "✅ Deployed $APP_NAME at https://$DOMAIN"
