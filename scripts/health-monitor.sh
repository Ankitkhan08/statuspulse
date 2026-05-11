#!/bin/bash

LOG_FILE="/var/log/statuspulse-monitor.log"
TELEGRAM_TOKEN="<8715405987:AAFarOWobOsOx-OubuF0CSCDfT1OqRTjqyY>"
CHAT_ID="985688378"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

send_alert() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        -d text="🚨 StatusPulse Server Alert: $message" > /dev/null
}

log "Starting health check..."

# 1. API Health Check
if ! curl -sf http://localhost:8000/health > /dev/null; then
    msg="API /health endpoint is DOWN!"
    log "$msg"
    send_alert "$msg"
fi

# 2. Container Status Check
if ! docker ps | grep -q statuspulse_app; then
    msg="statuspulse_app container is NOT running!"
    log "$msg"
    send_alert "$msg"
fi

# 3. Disk Usage Check (> 90%)
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 90 ]; then
    msg="High Disk Usage: ${DISK_USAGE}%"
    log "$msg"
    send_alert "$msg"
fi

# 4. Memory Usage Check (> 90%)
MEM_USAGE=$(free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100.0}')
if [ "$MEM_USAGE" -gt 90 ]; then
    msg="High Memory Usage: ${MEM_USAGE}%"
    log "$msg"
    send_alert "$msg"
fi

log "Health check complete."