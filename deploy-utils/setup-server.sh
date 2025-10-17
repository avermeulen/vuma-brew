#!/bin/bash
set -e
[ -f /var/deploy-utils/.env ] && set -o allexport && source /var/deploy-utils/.env && set +o allexport
apt update && apt install -y git nodejs npm nginx jq pm2 cron certbot python3-certbot-nginx
adduser --disabled-password --gecos "" $DEPLOY_USER || true
usermod -aG sudo $DEPLOY_USER
mkdir -p /var/{repos,www,deploy-utils}
[ ! -f /var/deploy-utils/ports.json ] && echo "{}" > /var/deploy-utils/ports.json
chown -R $DEPLOY_USER:$DEPLOY_USER /var/{repos,www,deploy-utils}
su - $DEPLOY_USER -c "pm2 startup systemd -u $DEPLOY_USER --hp $DEPLOY_HOME"
su - $DEPLOY_USER -c "pm2 save"
(crontab -l 2>/dev/null; echo '0 * * * * /usr/bin/pm2 save > /dev/null 2>&1') | crontab -
systemctl enable nginx
systemctl restart nginx
echo "✅ VumaBrew server setup complete."
