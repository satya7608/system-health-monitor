#!/bin/bash

# ================= CONFIG =================
CPU_WARN=70
CPU_CRIT=85
MEM_WARN=75
MEM_CRIT=90
DISK_WARN=80
DISK_CRIT=90

OUTPUT_DIR="./reports"
LOG_FILE="./monitor.log"
COOLDOWN=300   # 5 minutes

mkdir -p "$OUTPUT_DIR"

LAST_ALERT_FILE="./last_alert_time"

# ================= FUNCTIONS =================

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') : $1" >> "$LOG_FILE"
}

get_last_alert_time() {
    if [ -f "$LAST_ALERT_FILE" ]; then
        cat "$LAST_ALERT_FILE"
    else
        echo 0
    fi
}

update_alert_time() {
    date +%s > "$LAST_ALERT_FILE"
}

can_alert() {
    last=$(get_last_alert_time)
    now=$(date +%s)
    diff=$((now - last))

    if [ $diff -gt $COOLDOWN ]; then
        return 0
    else
        return 1
    fi
}

alert() {
    msg=$1
    if can_alert; then
        echo "[ALERT] $msg"
        log "$msg"
        update_alert_time
        python3 analyzer.py "$msg"
    fi
}

# ================= SYSTEM CHECK =================

cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
mem_usage=$(free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100}')
disk_usage=$(df / | awk 'END {print $5}' | sed 's/%//')

# ================= NETWORK CHECK =================

open_ports=$(ss -tuln | grep LISTEN | wc -l)
connections=$(ss -tun | wc -l)

# ================= REPORT =================

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT="$OUTPUT_DIR/report_$TIMESTAMP.txt"

echo "===== SYSTEM REPORT =====" > $REPORT
echo "Time: $(date)" >> $REPORT
echo "CPU Usage: $cpu_usage%" >> $REPORT
echo "Memory Usage: $mem_usage%" >> $REPORT
echo "Disk Usage: $disk_usage%" >> $REPORT
echo "Open Ports: $open_ports" >> $REPORT
echo "Connections: $connections" >> $REPORT

# ================= ALERT LOGIC =================

# CPU
if (( ${cpu_usage%.*} > CPU_CRIT )); then
    alert "CPU CRITICAL: $cpu_usage%"
elif (( ${cpu_usage%.*} > CPU_WARN )); then
    alert "CPU WARNING: $cpu_usage%"
fi

# Memory
if (( mem_usage > MEM_CRIT )); then
    alert "MEMORY CRITICAL: $mem_usage%"
elif (( mem_usage > MEM_WARN )); then
    alert "MEMORY WARNING: $mem_usage%"
fi

# Disk
if (( disk_usage > DISK_CRIT )); then
    alert "DISK CRITICAL: $disk_usage%"
elif (( disk_usage > DISK_WARN )); then
    alert "DISK WARNING: $disk_usage%"
fi

# Network
if (( open_ports > 50 )); then
    alert "Too many open ports: $open_ports"
fi
# ===== STATUS CALCULATION =====

if (( ${cpu_usage%.*} > CPU_CRIT )); then
    cpu_status="CRITICAL"
elif (( ${cpu_usage%.*} > CPU_WARN )); then
    cpu_status="WARNING"
else
    cpu_status="NORMAL"
fi

if (( mem_usage > MEM_CRIT )); then
    mem_status="CRITICAL"
elif (( mem_usage > MEM_WARN )); then
    mem_status="WARNING"
else
    mem_status="NORMAL"
fi

if (( disk_usage > DISK_CRIT )); then
    disk_status="CRITICAL"
elif (( disk_usage > DISK_WARN )); then
    disk_status="WARNING"
else
    disk_status="NORMAL"
fi

# ===== SMART WARNINGS =====

if (( ${cpu_usage%.*} > CPU_WARN )); then
    echo "⚠ High CPU usage detected!" >> $REPORT
fi

if (( mem_usage > MEM_WARN )); then
    echo "⚠ High Memory usage detected!" >> $REPORT
fi

if (( disk_usage > DISK_WARN )); then
    echo "⚠ Disk space running low!" >> $REPORT
fi
# ================= END =================

log "Scan completed"
echo "Report saved: $REPORT"
