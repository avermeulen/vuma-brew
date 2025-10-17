#!/bin/bash
set -e
echo "🚀 Installing VumaBrew CLI"
read -p "🔗 Enter server hostname/IP: " SERVER_HOST
read -p "👤 Enter SSH user (default: deploy): " SERVER_USER
SERVER_USER=${SERVER_USER:-deploy}
ENV_FILE="$HOME/.deploy.env"
cat <<ENVEOF > "$ENV_FILE"
DEPLOY_SERVER_USER="$SERVER_USER"
DEPLOY_SERVER_HOST="$SERVER_HOST"
DEPLOY_SERVER="\$DEPLOY_SERVER_USER@\${DEPLOY_SERVER_HOST}"
DEPLOY_UTILS_PATH="/var/deploy-utils"
ENVEOF
chmod 600 "$ENV_FILE"
mkdir -p "$HOME/bin"
cat <<'EOS' > "$HOME/bin/deploy"
#!/bin/bash
set -e
[ -f "$HOME/.deploy.env" ] && set -o allexport && source "$HOME/.deploy.env" && set +o allexport || (echo "⚠️ ~/.deploy.env missing"; exit 1)
CMD=$1; APP=$2
if [ "$CMD" == "new" ]; then
  RESULT=$(ssh -o StrictHostKeyChecking=no "$DEPLOY_SERVER" "sudo -u $DEPLOY_SERVER_USER $DEPLOY_UTILS_PATH/create-app.sh $APP")
  NAME=$(echo "$RESULT" | jq -r '.name'); DOMAIN=$(echo "$RESULT" | jq -r '.domain'); REPO=$(echo "$RESULT" | jq -r '.repo')
  echo "✅ App $NAME → $DOMAIN"
  git remote remove production 2>/dev/null
  git remote add production "$DEPLOY_SERVER:$REPO"
  echo "Push with: git push production main"
  exit 0
fi
[ "$CMD" == "list" ] && ssh "$DEPLOY_SERVER" "sudo -u $DEPLOY_SERVER_USER $DEPLOY_UTILS_PATH/list-apps.sh" && exit 0
[ "$CMD" == "delete" ] && ssh "$DEPLOY_SERVER" "sudo -u $DEPLOY_SERVER_USER $DEPLOY_UTILS_PATH/delete-app.sh $APP" && exit 0
echo "Usage: deploy new [name] | deploy list | deploy delete <name>"
EOS
chmod +x "$HOME/bin/deploy"
[[ ":$PATH:" != *":$HOME/bin:"* ]] && echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
echo "✅ VumaBrew CLI installed. Try: deploy new myapp"
