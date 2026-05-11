#!/bin/bash
set -e

BACKUP_DIR="/home/ubuntu/backups"
CONTAINER_NAME="statuspulse_postgres"
DB_USER="statuspulse_user"
DB_NAME="statuspulse"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
FILE_NAME="pg_backup_$DATE.sql.gz"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

log "Starting PostgreSQL backup..."
mkdir -p "$BACKUP_DIR"

# Run pg_dump inside the container and compress it
docker exec $CONTAINER_NAME pg_dump -U $DB_USER -d $DB_NAME | gzip > "$BACKUP_DIR/$FILE_NAME"

log "Backup saved to $BACKUP_DIR/$FILE_NAME"

# Delete backups older than 7 days (Rotation)
log "Cleaning up backups older than 7 days..."
find "$BACKUP_DIR" -type f -name "pg_backup_*.sql.gz" -mtime +7 -exec rm {} \;

log "Backup process complete."