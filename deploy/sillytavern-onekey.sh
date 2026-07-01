#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/sillytavern}"
PORT="${PORT:-8000}"
IMAGE="${IMAGE:-ghcr.io/sillytavern/sillytavern:latest}"
CONTAINER_NAME="${CONTAINER_NAME:-sillytavern}"
MODE="${MODE:-image}"
SOURCE_DIR="${SOURCE_DIR:-}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed or not in PATH."
  exit 1
fi

if docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
else
  echo "Docker Compose is not available. Install the Docker Compose plugin first."
  exit 1
fi

mkdir -p \
  "$APP_DIR/config" \
  "$APP_DIR/data" \
  "$APP_DIR/plugins" \
  "$APP_DIR/extensions"

if [ "$MODE" = "source" ]; then
  if [ -z "$SOURCE_DIR" ]; then
    SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  fi

  if [ ! -f "$SOURCE_DIR/package.json" ] || [ ! -f "$SOURCE_DIR/Dockerfile" ]; then
    echo "SOURCE_DIR must point to a SillyTavern source checkout with package.json and Dockerfile."
    exit 1
  fi

  IMAGE="sillytavern-local:latest"
  BUILD_BLOCK="    build:
      context: \"${SOURCE_DIR}\""
else
  BUILD_BLOCK=""
fi

cat > "$APP_DIR/docker-compose.yml" <<YAML
services:
  sillytavern:
${BUILD_BLOCK}
    image: ${IMAGE}
    container_name: ${CONTAINER_NAME}
    hostname: sillytavern
    environment:
      - NODE_ENV=production
      - FORCE_COLOR=1
      - SILLYTAVERN_HEARTBEATINTERVAL=30
    ports:
      - "${PORT}:8000"
    volumes:
      - "./config:/home/node/app/config"
      - "./data:/home/node/app/data"
      - "./plugins:/home/node/app/plugins"
      - "./extensions:/home/node/app/public/scripts/extensions/third-party"
    healthcheck:
      test: ["CMD", "node", "src/healthcheck.js"]
      interval: 30s
      timeout: 10s
      start_period: 20s
      retries: 3
    restart: unless-stopped
YAML

cd "$APP_DIR"

if [ "$MODE" = "source" ]; then
  echo "Building image from source: $SOURCE_DIR"
  $COMPOSE build --pull
else
  echo "Pulling image: $IMAGE"
  docker pull "$IMAGE"
fi

echo "Starting SillyTavern in $APP_DIR on port $PORT"
$COMPOSE up -d

echo
echo "SillyTavern is starting."
echo "Open: http://YOUR_SERVER_IP:${PORT}"
echo
echo "Useful commands:"
echo "  cd $APP_DIR && $COMPOSE ps"
echo "  cd $APP_DIR && $COMPOSE logs -f"
if [ "$MODE" = "source" ]; then
  echo "  cd $APP_DIR && $COMPOSE build --pull && $COMPOSE up -d"
else
  echo "  cd $APP_DIR && $COMPOSE pull && $COMPOSE up -d"
fi
