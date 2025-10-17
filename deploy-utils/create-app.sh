#!/bin/bash
set -e
[ -f /var/deploy-utils/.env ] && set -o allexport && source /var/deploy-utils/.env && set +o allexport
PORT_FILE="/var/deploy-utils/ports.json"
APP_NAME=$1
ADJECTIVES=(brave calm bright cozy swift lucky fresh quiet clever)
ANIMALS=(otter fox crane dolphin panda wolf sparrow bear owl)
if [ -z "$APP_NAME" ]; then
  A=${ADJECTIVES[$RANDOM % ${#ADJECTIVES[@]}]}
  B=${ANIMALS[$RANDOM % ${#ANIMALS[@]}]}
  APP_NAME="${A}-${B}"
fi
DOMAIN="${APP_NAME}.${BASE_DOMAIN}"
[ ! -f "$PORT_FILE" ] && echo "{}" > "$PORT_FILE"
LAST_PORT=$(jq -r 'values | max // 4173' "$PORT_FILE")
NEW_PORT=$((LAST_PORT + 1))
jq --arg app "$APP_NAME" --argjson port $NEW_PORT '. + {($app): $port}' "$PORT_FILE" > tmp.$$.json && mv tmp.$$.json "$PORT_FILE"
REPO_PATH="/var/repos/${APP_NAME}.git"
mkdir -p "$REPO_PATH"
cd "$REPO_PATH" && git init --bare
cat <<HOOK > hooks/post-receive
#!/bin/bash
/var/deploy-utils/deploy-hook.sh $APP_NAME $DOMAIN $NEW_PORT
HOOK
chmod +x hooks/post-receive
jq -n --arg name "$APP_NAME" --arg domain "$DOMAIN" --arg port "$NEW_PORT" --arg repo "$REPO_PATH" \
  '{name:$name,domain:$domain,port:$port,repo:$repo}'
