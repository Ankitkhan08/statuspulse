#!/bin/bash
set -e

REPO_DIR="/home/ubuntu/statuspulse"
IMAGE="ghcr.io/ankitkhan08/statuspulse"
HEALTH_URL="http://localhost:8000/health"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

log "Starting deployment..."
cd $REPO_DIR

log "Pulling latest image..."
docker pull $IMAGE:latest

log "Updating stack..."
docker compose up -d --pull always

log "Running health check..."
for i in $(seq 1 10); do
    if curl -sf $HEALTH_URL > /dev/null 2>&1; then
        log "Health check passed! Deployment successful."
        exit 0
    fi
    log "Attempt $i/10 - waiting 5s..."
    sleep 5
done

log "Health check FAILED - rolling back..."
docker compose down
docker compose up -d
log "Rollback complete."
exit 1
