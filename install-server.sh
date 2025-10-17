#!/bin/bash
set -e
REPO_URL="https://github.com/andrevermeulen/vuma-brew.git"
read -p "🌍 Enter base domain (e.g. apps.domain.com): " BASE_DOMAIN
read -p "📧 Admin email: " ADMIN_EMAIL
mkdir -p /var/deploy-utils
cat <<ENVEOF > /var/deploy-utils/.env
BASE_DOMAIN="$BASE_DOMAIN"
ADMIN_EMAIL="$ADMIN_EMAIL"
USE_WILDCARD_SSL=true
CERTBOT_EMAIL="$ADMIN_EMAIL"
DEFAULT_NODE_PORT=4173
DEPLOY_USER="deploy"
DEPLOY_HOME="/home/deploy"
ENVEOF
apt update && apt install -y git jq curl
git clone $REPO_URL /opt/vuma-brew || (cd /opt/vuma-brew && git pull)
cp /opt/vuma-brew/deploy-utils/*.sh /var/deploy-utils/
chmod +x /var/deploy-utils/*.sh
/var/deploy-utils/setup-server.sh
echo "✅ VumaBrew installed and configured at /var/deploy-utils"
