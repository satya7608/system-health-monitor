#!/bin/bash

################################################################################
# COMPLETE SYSTEM HEALTH MONITORING SCRIPT
# Comprehensive System Diagnostics & Health Report
################################################################################
#
# Features:
# - System Information
# - CPU Information & Usage
# - Memory Information & Usage
# - Disk Information & Usage
# - Network Information & Statistics
# - Process Information
# - User Information
# - Temperature Monitoring
# - Battery Information
# - Virus/Security Alert
# - Running Services Status
# - Email Alert System
# - System Uptime
# - Complete Health Report Generation
#
# Author: Your Name
# Version: 1.0
# Date: 2025-01-23
# Usage: sudo ./system_health_monitor.sh
#
################################################################################

# ═══════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════

# Email Configuration (Set your email details here)
ENABLE_EMAIL_ALERT="no"  # Change to "yes" to enable email alerts
ADMIN_EMAIL="admin@example.com"
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USER="your-email@gmail.com"
SMTP_PASSWORD="your-app-password"

# Alert Thresholds
CPU_WARNING=70
CPU_CRITICAL=85
MEMORY_WARNING=75
MEMORY_CRITICAL=90
DISK_WARNING=80
DISK_CRITICAL=90
TEMP_WARNING=70
TEMP_CRITICAL=80

# Output Directory
OUTPUT_DIR="./health_reports"
mkdir -p "$OUTPUT_DIR"

# Report Files
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$OUTPUT_DIR/health_report_$TIMESTAMP.txt"
HTML_REPORT="$OUTPUT_DIR/health_report_$TIMESTAMP.html"
ALERT_FILE="$OUTPUT_DIR/alerts_$TIMESTAMP.txt"

# ═══════════════════════════════════════════════════════════════
# COLOR CODES
# ═══════════════════════════════════════════════════════════════

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# ═══════════════════════════════════════════════════════════════
# ALERT FUNCTIONS
# ═══════════════════════════════════════════════════════════════

alert_critical() {
    echo -e "${RED}[CRITICAL ALERT] $1${NC}"
    echo "[$(date)] CRITICAL: $1" >> "$ALERT_FILE"
}

alert_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
    echo "[$(date)] WARNING: $1" >> "$ALERT_FILE"
}

alert_info() {
    echo -e "${GREEN}[INFO] $1${NC}"
}

# ═══════════════════════════════════════════════════════════════
# BANNER
# ═══════════════════════════════════════════════════════════════

print_banner() {
    clear
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}                    COMPLETE SYSTEM HEALTH MONITORING SYSTEM${NC}"
    echo -e "${CYAN}                    Comprehensive Diagnostics & Health Report${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Scan Start Time:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${YELLOW}Report File:${NC} $REPORT_FILE"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# 1. SYSTEM INFORMATION
# ═══════════════════════════════════════════════════════════════

check_system_info() {
    echo -e "\n${BOLD}${GREEN}[1/14] SYSTEM INFORMATION${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    
    # Basic System Info
    local hostname=$(hostname)
    local os_name=$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown")
    local kernel=$(uname -r)
    local arch=$(uname -m)
    local date_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "  Hostname:        ${YELLOW}$hostname${NC}"
    echo "  Operating System: ${YELLOW}$os_name${NC}"
    echo "  Kernel Version:   ${YELLOW}$kernel${NC}"
    echo "  Architecture:     ${YELLOW}$arch${NC}"
    echo "  Current Date/Time: ${YELLOW}$date_time${NC}"
    
    # Additional Details
    if [ -f /etc/lsb-release ]; then
        local distro=$(cat /etc/lsb-release | grep DISTRIB_DESCRIPTION | cut -d'"' -f2)
        echo "  Distribution:     ${YELLOW}$distro${NC}"
    fi
    
    # Timezone
    local timezone=$(timedatectl 2>/dev/null | grep "Time zone" | awk '{print $3}' || date +%Z)
    echo "  Timezone:         ${YELLOW}$timezone${NC}"
    
    # Virtualization
    local virt=$(systemd-detect-virt 2>/dev/null || echo "none")
    echo "  Virtualization:   ${YELLOW}$virt${NC}"
}

# ═══════════════════════════════════════════════════════════════
# 2. SYSTEM UPTIME
# ═══════════════════════════════════════════════════════════════

check_uptime() {
    echo -e "\n${BOLD}${GREEN}[2/14] SYSTEM UPTIME${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    
    local uptime_info=$(uptime -p 2>/dev/null || uptime)
    local boot_time=$(who -b 2>/dev/null | awk '{print $3, $4}' || uptime -s)
    local current_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "  Current Time:     ${YELLOW}$current_time${NC}"
    echo "  Boot Time:        ${YELLOW}$boot_time${NC}"
    echo "  Uptime:           ${YELLOW}$uptime_info${NC}"
    
    # Load average
    local load_avg=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
    echo "  Load Average:     ${YELLOW}$load_avg${NC} (1min, 5min, 15min)"
}

# ═══════════════════════════════════════════════════════════════
# 3. CPU INFORMATION & USAGE
# ═══════════════════════════════════════════════════════════════

check_cpu() {
    echo -e "\n${BOLD}${GREEN}[3/14] CPU INFORMATION & USAGE${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    
    # CPU Model
    local cpu_model=$(grep -m1 "model name" /proc/cpuinfo | cut -d':' -f2 | xargs)
    local physical_cores=$(grep "^physical id" /proc/cpuinfo | sort -u | wc -l)
    local logical_cores=$(nproc)
    local cpu_mhz=$(grep "^cpu MHz" /proc/cpuinfo | head -1 | awk '{print $4}')
    
    echo "  CPU Model:        ${YELLOW}$cpu_model${NC}"
    echo "  Physical Cores:   ${YELLOW}$physical_cores${NC}"
    echo "  Logical Cores:    ${YELLOW}$logical_cores${NC}"
    echo "  CPU Frequency:    ${YELLOW}${cpu_mhz} MHz${NC}"
    
    # CPU Usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    # Determine color based on usage
    local cpu_color=$GREEN
    if (( $(echo "$cpu_usage > $CPU_CRITICAL" | bc -l) )); then
        cpu_color=$RED
        alert_critical "CPU usage is critical: ${cpu_usage}%"
    elif (( $(echo "$cpu_usage > $CPU_WARNING" | bc -l) )); then
        cpu_color=$YELLOW
        alert_warning "CPU usage is high: ${cpu_usage}%"
    fi
    
    echo -e "  CPU Usage:        ${cpu_color}${cpu_usage}%${NC}"
    
    # Progress bar
    local bar_length=60
    local filled=$(echo "$cpu_usage / 100 * $bar_length" | bc)
    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=filled; i<bar_length; i++)); do bar="${bar}░"; done
    echo -e "  ${cpu_color}[$bar] ${cpu_usage}%${NC}"
    
    # Per-core usage
    echo -e "\n  ${BOLD}Per-Core Usage:${NC}"
    local core_num=0
    while read -r line; do
        local core_usage=$(echo "$line" | awk '{print $2}')
        local core_bar_filled=$(echo "$core_usage / 100 * 30" | bc)
        local core_bar=""
        for ((i=0; i<core_bar_filled; i++)); do core_bar="${core_bar}█"; done
        for ((i=core_bar_filled; i<30; i++)); do core_bar="${core_bar}░"; done
        
        local core_color=$GREEN
        [[ $(echo "$core_usage > 80" | bc) -eq 1 ]] && core_color=$RED
        [[ $(echo "$core_usage > 60" | bc) -eq 1 ]] && [[ $(echo "$core_usage <= 80" | bc) -eq 1 ]] && core_color=$YELLOW
        
        printf "    Core %2d: ${core_color}[%s] %5.1f%%${NC}\n" "$core_num" "$core_bar" "$core_usage"
        ((core_num++))
    done < <(mpstat -P ALL 1 1 2>/dev/null | awk '/Average:/ && $2 ~ /[0-9]/ {print $2, 100-$NF}' || echo "0 0")
}

# ═══════════════════════════════════════════════════════════════
# 4. MEMORY INFORMATION
# ═══════════════════════════════════════════════════════════════

check_memory() {
    echo -e "\n${BOLD}${GREEN}[4/14] MEMORY INFORMATION${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    
    # RAM Information
    local mem_total=$(free -m | awk 'NR==2{print $2}')
    local mem_used=$(free -m | awk 'NR==2{print $3}')
    local mem_free=$(free -m | awk 'NR==2{print $4}')
    local mem_available=$(free -m | awk 'NR==2{print $7}')
    local mem_usage=$(free | awk 'NR==2{printf "%.2f", $3*100/$2}')
    
    echo "  ${BOLD}RAM Information:${NC}"
    echo "    Total Memory:     ${YELLOW}${mem_total} MB${NC}"
    echo "    Used Memory:      ${YELLOW}${mem_used} MB${NC}"
    echo "    Free Memory:      ${YELLOW}${mem_free} MB${NC}"
    echo "    Available Memory: ${YELLOW}${mem_available} MB${NC}"
    
    # Memory usage bar
    local mem_color=$GREEN
    if (( $(echo "$mem_usage > $MEMORY_CRITICAL" | bc -l) )); then
        mem_color=$RED
        alert_critical "Memory usage is critical: ${mem_usage}%"
    elif (( $(echo "$mem_usage > $MEMORY_WARNING" | bc -l) )); then
        mem_color=$YELLOW
        alert_warning "Memory usage is high: ${mem_usage}%"
    fi
    
    echo -e "    Memory Usage:     ${mem_color}${mem_usage}%${NC}"
    
    local bar_length=60
    local filled=$(echo "$mem_usage / 100 * $bar_length" | bc)
    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=filled; i<bar_length; i++)); do bar="${bar}░"; done
    echo -e "    ${mem_color}[$bar] ${mem_usage}%${NC}"
    
    # SWAP Information
    echo -e "\n  ${BOLD}SWAP Information:${NC}"
    local swap_total=$(free -m | awk 'NR==3{print $2}')
    local swap_used=$(free -m | awk 'NR==3{print $3}')
    local swap_free=$(free -m | awk 'NR==3{print $4}')
    local swap_usage=0
    
    if [ "$swap_total" -gt 0 ]; then
        swap_usage=$(free | awk 'NR==3{printf "%.2f", $3*100/$2}')
    fi
    
    echo "    Total SWAP:       ${YELLOW}${swap_total} MB${NC}"
    echo "    Used SWAP:        ${YELLOW}${swap_used} MB${NC}"
    echo "    Free SWAP:        ${YELLOW}${swap_free} MB${NC}"
    echo "    SWAP Usage:       ${YELLOW}${swap_usage}%${NC}"
}

# ═══════════════════════════════════════════════════════════════
# 5. DISK INFORMATION
# ═══════════════════════════════════════════════════════════════

check_disk() {
    echo -e "\n${BOLD}${GREEN}[5/14] DISK INFORMATION${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    
    echo -e "  ${BOLD}Disk Partitions:${NC}\n"
    
    df -h | grep -vE '^Filesystem|tmpfs|cdrom|loop' | while read line; do
        local device=$(echo $line | awk '{print $1}')
        local size=$(echo $line | awk '{print $2}')
        local used=$(echo $line | awk '{print $3}')
        local avail=$(echo $line | awk '{print $4}')
        local usage=$(echo $line | awk '{print $5}' | tr -d '%')
        local mount=$(echo $line | awk '{print $6}')
        
        # Determine color
        local disk_color=$GREEN
        if [ "$usage" -gt "$DISK_CRITICAL" ]; then
            disk_color=$RED
            alert_critical "Disk usage critical on $mount: ${usage}%"
        elif [ "$usage" -gt "$DISK_WARNING" ]; then
            disk_color=$YELLOW
            alert_warning "Disk usage high on $mount: ${usage}%"
        fi
        
        echo "    Device: ${YELLOW}$device${NC}"
        echo "    Mount Point: ${YELLOW}$mount${NC}"
        echo "    Size: $size | Used: $used | Available: $avail"
        echo -e "    Usage: ${disk_color}${usage}%${NC}"
        
        # Progress bar
        local bar_length=50
        local filled=$(echo "$usage * $bar_length / 100" | bc)
        local bar=""
        for ((i=0; i<filled; i++)); do bar="${bar}█"; done
        for ((i=filled; i<bar_length; i++)); do bar="${bar}░"; done
        echo -e "    ${disk_color}[$bar]${NC}\n"
    done
    
    # Disk I/O Statistics
    echo -e "  ${BOLD}Disk I/O Statistics:${NC}"
    if command -v iostat &> /dev/null; then
        iostat -d -h | tail -n +3 | head -10
    else
        echo "    iostat not installed. Install sysstat package for I/O stats."
    fi
}

# ═══════════════════════════════════════════════════════════════
# 6. NETWORK INFORMATION
# ═══════════════════════════════════════════════════════════════

check_network() {
    echo -e "\n${BOLD}${GREEN}[6/14] NETWORK INFORMATION${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    
    # Network Interfaces
    echo -e "  ${BOLD}Network Interfaces:${NC}\n"
    
    ip -br addr show | while read line; do
        local iface=$(echo $line | awk '{print $1}')
        local status=$(echo $line | awk '{print $2}')
        local ip_addr=$(echo $line | awk '{print $3}')
        
        local status_color=$RED
        [[ "$status" == "UP" ]] && status_color=$GREEN
        
        echo -e "    Interface: ${YELLOW}$iface${NC}"
        echo -e "    Status: ${status_color}$status${NC}"
        echo -e "    IP Address: ${YELLOW}$ip_addr${NC}\n"
    done
    
    # Network Statistics
    echo -e "  ${BOLD}Network Statistics:${NC}"
    
    local rx_bytes=$(cat /sys/class/net/eth0/statistics/rx_bytes 2>/dev/null || echo 0)
    local tx_bytes=$(cat /sys/class/net/eth0/statistics/tx_bytes 2>/dev/null || echo 0)
    
    # Convert to MB
    local rx_mb=$(echo "scale=2; $rx_bytes / 1024 / 1024" | bc)
    local tx_mb=$(echo "scale=2; $tx_bytes / 1024 / 1024" | bc)
    
    echo "    Received (RX):    ${YELLOW}${rx_mb} MB${NC}"
    echo "    Transmitted (TX): ${YELLOW}${tx_mb} MB${NC}"
    
    # Active Connections
    echo -e "\n  ${BOLD}Active Connections:${NC}"
    local connections=$(ss -s 2>/dev/null || netstat -s 2>/dev/null | grep "connections established" || echo "N/A")
    echo "    $connections"
    
    # Open Ports
    echo -e "\n  ${BOLD}Listening Ports:${NC}"
    ss -tulpn 2>/dev/null | grep LISTEN | head -10 || netstat -tulpn 2>/dev/null | grep LISTEN | head -10
}

# ═══════════════════════════════════════════════════════════════
# 7. PROCESS INFORMATION
# ═══════════════════════════════════════════════════════════════

check_processes() {
    echo -e "\n${BOLD}${GREEN}[7/14] PROCESS INFORMATION${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    
    # Total Processes
    local total_procs=$(ps aux | wc -l)
    local running_procs=$(ps aux | grep -c " R ")
    local sleeping_procs=$(ps aux | grep -c " S ")
    
    echo "  Total Processes:  ${YELLOW}$total_procs${NC}"
    echo "  Running:          ${YELLOW}$running_procs${NC}"
    echo "  Sleeping:         ${YELLOW}$sleeping_procs${NC}"
    
    # Top CPU Consuming Processes
    echo -e "\n  ${BOLD}Top 10 CPU Consuming Processes:${NC}"
    printf "    ${YELLOW}%-8s %-8s %-8s %-50s${NC}\n" "PID" "CPU%" "MEM%" "COMMAND"
    echo "    ──────────────────────────────────────────────────────────────────────────"
    ps aux --sort=-%cpu | head -11 | tail -10 | awk '{printf "    %-8s %-8s %-8s %-50s\n", $2, $3, $4, substr($11,1,50)}'
    
    # Top Memory Consuming Processes
    echo -e "\n  ${BOLD}Top 10 Memory Consuming Processes:${NC}"
    printf "    ${YELLOW}%-8s %-8s %-8s %-50s${NC}\n" "PID" "CPU%" "MEM%" "COMMAND"
    echo "    ──────────────────────────────────────────────────────────────────────────"
    ps aux --sort=-%mem | head -11 | tail -10 | awk '{printf "    %-8s %-8s %-8s %-50s\n", $2, $3, $4, substr($11,1,50)}'
}

# ═══════════════════════════════════════════════════════════════
# 8. USER INFORMATION
# ═══════════════════════════════════════════════════════════════

check_users() {
    echo -e "\n${BOLD}${GREEN}[8/14] USER INFORMATION${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    
    # Currently Logged In Users
    echo -e "  ${BOLD}Currently Logged In Users:${NC}"
    
    if who | grep -q .; then
        printf "    ${YELLOW}%-15s %-10s %-20s %-20s${NC}\n" "USER" "TTY" "LOGIN TIME" "HOST"
        echo "    ──────────────────────────────────────────────────────────────────────────"
        who | awk '{printf "    %-15s %-10s %-20s %-20s\n", $1, $2, $3" "$4, $5}'
    else
        echo "    No users currently logged in"
    fi
    
    # Total User Accounts
    echo -e "\n  ${BOLD}User Account Summary:${NC}"
    local total_users=$(cat /etc/passwd | wc -l)
    local system_users=$(awk -F: '$3 < 1000 {print $1}' /etc/passwd | wc -l)
    local regular_users=$(awk -F: '$3 >= 1000 {print $1}' /etc/passwd | wc -l)
    
    echo "    Total Accounts:   ${YELLOW}$total_users${NC}"
    echo "    System Accounts:  ${YELLOW}$system_users${NC}"
    echo "    Regular Users:    ${YELLOW}$regular_users${NC}"
    
    # Last Logins
    echo -e "\n  ${BOLD}Last 5 Logins:${NC}"
    last -n 5 -F 2>/dev/null || last -n 5
}

# ═══════════════════════════════════════════════════════════════
# 9. TEMPERATURE MONITORING
# ═══════════════════════════════════════════════════════════════

check_temperature() {
    echo -e "\n${BOLD}${GREEN}[9/14] TEMPERATURE MONITORING${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    
    if command -v sensors &> /dev/null; then
        sensors 2>/dev/null | grep -E "Core|temp" | while read line; do
            local temp=$(echo "$line" | grep -oP '\+\d+\.\d+°C' | head -1 | tr -d '+°C')
            
            if [ -n "$temp" ]; then
                local temp_color=$GREEN
                if (( $(echo "$temp > $TEMP_CRITICAL" | bc -l) )); then
                    temp_color=$RED
                    alert_critical "Temperature critical: ${temp}°C"
                elif (( $(echo "$temp > $TEMP_WARNING" | bc -l) )); then
                    temp_color=$YELLOW
                    alert_warning "Temperature high: ${temp}°C"
                fi
                
                echo -e "    $line" | sed "s/+\([0-9.]*\)°C/${temp_color}+\1°C${NC}/"
            fi
        done
    else
        echo "    lm-sensors not installed. Install with: sudo apt install lm-sensors"
        echo "    Then run: sudo sensors-detect"
        
        # Try alternative method
        if [ -d /sys/class/thermal ]; then
            echo -e "\n    ${BOLD}Thermal Zones:${NC}"
            for zone in /sys/class/thermal/thermal_zone*/; do
                if [ -f "${zone}temp" ]; then
                    local temp=$(cat "${zone}temp")
                    local temp_c=$(echo "scale=1; $temp / 1000" | bc)
                    echo "      $(basename $zone): ${YELLOW}${temp_c}°C${NC}"
                fi
            done
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════
# 10. BATTERY INFORMATION
# ═══════════════════════════════════════════════════════════════

check_battery() {
    echo -e "\n${BOLD}${GREEN}[10/14] BATTERY INFORMATION${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    
    if [ -d /sys/class/power_supply/BAT0 ] || [ -d /sys/class/power_supply/BAT1 ]; then
        for battery in /sys/class/power_supply/BAT*; do
            if [ -f "$battery/capacity" ]; then
                local capacity=$(cat "$battery/capacity")
                local status=$(cat "$battery/status")
                
                local bat_color=$GREEN
                [ "$capacity" -lt 20 ] && bat_color=$RED
                [ "$capacity" -lt 50 ] && [ "$capacity" -ge 20 ] && bat_color=$YELLOW
                
                echo "    Battery: ${YELLOW}$(basename $battery)${NC}"
                echo -e "    Capacity: ${bat_color}${capacity}%${NC}"
                echo "    Status: ${YELLOW}$status${NC}"
                
                # Battery bar
                local bar_length=50
                local filled=$(echo "$capacity * $bar_length / 100" | bc)
                local bar=""
                for ((i=0; i<filled; i++)); do bar="${bar}█"; done
                for ((i=filled; i<bar_length; i++)); do bar="${bar}░"; done
                echo -e "    ${bat_color}[$bar] ${capacity}%${NC}"
                
                if [ "$capacity" -lt 20 ]; then
                    alert_warning "Battery low: ${capacity}%"
                fi
            fi
        done
    else
        echo "    No battery detected (Desktop system or battery not accessible)"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 11. VIRUS/SECURITY ALERT
# ═══════════════════════════════════════════════════════════════

check_security() {
    echo -e "\n${BOLD}${GREEN}[11/14] VIRUS & SECURITY SCAN${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    
    # Failed Login Attempts
    echo -e "  ${BOLD}Security Checks:${NC}\n"
    
    echo "    1. Failed Login Attempts:"
    local failed_logins=$(grep "Failed password" /var/log/auth.log 2>/dev/null | tail -20 | wc -l || echo 0)
    
    if [ "$failed_logins" -gt 5 ]; then
        echo -e "       ${RED}⚠️  Found $failed_logins failed login attempts${NC}"
        alert_critical "Multiple failed login attempts: $failed_logins"
    else
        echo -e "       ${GREEN}✓ Failed logins: $failed_logins (Normal)${NC}"
    fi
    
    # Root Login Check
    echo -e "\n    2. Root SSH Login:"
    if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config 2>/dev/null; then
        echo -e "       ${RED}⚠️  Root SSH login is ENABLED (Security Risk)${NC}"
        alert_warning "Root SSH login is enabled"
    else
        echo -e "       ${GREEN}✓ Root SSH login is disabled${NC}"
    fi
    
    # Firewall Status
    echo -e "\n    3. Firewall Status:"
    if systemctl is-active --quiet firewalld 2>/dev/null || systemctl is-active --quiet ufw 2>/dev/null; then
        echo -e "       ${GREEN}✓ Firewall is active${NC}"
    else
        echo -e "       ${RED}⚠️  Firewall is not active${NC}"
        alert_warning "Firewall is not active"
    fi
    
    # Check for suspicious processes
    echo -e "\n    4. Suspicious Process Check:"
    local suspicious_procs=0
    for proc in nc netcat nmap masscan; do
        if pgrep -x "$proc" > /dev/null; then
            echo -e "       ${RED}⚠️  Suspicious process found: $proc${NC}"
            alert_critical "Suspicious process detected: $proc"
            ((suspicious_procs++))
        fi
    done
    
    if [ "$suspicious_procs" -eq 0 ]; then
        echo -e "       ${GREEN}✓ No suspicious processes detected${NC}"
    fi
    
    # Check world-writable files in critical directories
    echo -e "\n    5. World-Writable Files Check:"
    local writable_files=$(find /etc /bin /sbin -type f -perm -002 2>/dev/null | wc -l)
    
    if [ "$writable_files" -gt 0 ]; then
        echo -e "       ${RED}⚠️  Found $writable_files world-writable files in system directories${NC}"
        alert_warning "World-writable files found: $writable_files"
    else
        echo -e "       ${GREEN}✓ No world-writable files in critical directories${NC}"
    fi
    
    # ClamAV scan (if installed)
    echo -e "\n    6. Antivirus Scan:"
    if command -v clamscan &> /dev/null; then
        echo "       Running quick scan of /tmp..."
        clamscan -r -i /tmp 2>/dev/null | tail -5
    else
        echo "       ClamAV not installed. Install with: sudo apt install clamav"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 12. RUNNING SERVICES STATUS
# ═══════════════════════════════════════════════════════════════

check_services() {
    echo -e "\n${BOLD}${GREEN}[12/14] RUNNING SERVICES STATUS${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    
    echo -e "  ${BOLD}Active Services:${NC}\n"
    
    # List all running services
    systemctl list-units --type=service --state=running --no-pager 2>/dev/null | grep '.service' | head -20 | while read line; do
        local service=$(echo "$line" | awk '{print $1}' | sed 's/.service//')
        local status=$(echo "$line" | awk '{print $3}')
        
        if [ "$status" == "running" ]; then
            echo -e "    ${GREEN}✓${NC} ${YELLOW}$service${NC}"
        else
            echo -e "    ${RED}✗${NC} ${YELLOW}$service${NC} - $status"
        fi
    done
    
    # Failed Services
    echo -e "\n  ${BOLD}Failed Services:${NC}"
    local failed=$(systemctl list-units --type=service --state=failed --no-pager 2>/dev/null | grep '.service' | wc -l)
    
    if [ "$failed" -gt 0 ]; then
        echo -e "    ${RED}⚠️  $failed service(s) have failed${NC}"
        systemctl list-units --type=service --state=failed --no-pager 2>/dev/null | grep '.service'
        alert_warning "$failed services have failed"
    else
        echo -e "    ${GREEN}✓ No failed services${NC}"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 13. SYSTEM HEALTH REPORT
# ═══════════════════════════════════════════════════════════════

generate_health_report() {
    echo -e "\n${BOLD}${GREEN}[13/14] SYSTEM HEALTH REPORT${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    
    # Calculate overall health score
    local health_score=100
    
    # CPU check
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    if (( $(echo "$cpu_usage > 85" | bc -l) )); then
        health_score=$((health_score - 20))
    elif (( $(echo "$cpu_usage > 70" | bc -l) )); then
        health_score=$((health_score - 10))
    fi
    
    # Memory check
    local mem_usage=$(free | awk 'NR==2{printf "%.2f", $3*100/$2}')
    if (( $(echo "$mem_usage > 90" | bc -l) )); then
        health_score=$((health_score - 20))
    elif (( $(echo "$mem_usage > 75" | bc -l) )); then
        health_score=$((health_score - 10))
    fi
    
    # Disk check
    local disk_usage=$(df / | awk 'NR==2{print $5}' | tr -d '%')
    if [ "$disk_usage" -gt 90 ]; then
        health_score=$((health_score - 20))
    elif [ "$disk_usage" -gt 80 ]; then
        health_score=$((health_score - 10))
    fi
    
    # Display health score
    local health_color=$GREEN
    local health_status="EXCELLENT"
    
    if [ "$health_score" -lt 60 ]; then
        health_color=$RED
        health_status="CRITICAL"
    elif [ "$health_score" -lt 80 ]; then
        health_color=$YELLOW
        health_status="WARNING"
    fi
    
    echo -e "  ${BOLD}Overall System Health Score:${NC}"
    echo -e "  ${health_color}${BOLD}$health_score / 100 - $health_status${NC}"
    
    # Health bar
    local bar_length=60
    local filled=$(echo "$health_score * $bar_length / 100" | bc)
    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=filled; i<bar_length; i++)); do bar="${bar}░"; done
    echo -e "  ${health_color}[$bar] $health_score%${NC}"
    
    # Summary
    echo -e "\n  ${BOLD}Health Summary:${NC}"
    echo "    CPU Usage:        ${cpu_usage}%"
    echo "    Memory Usage:     ${mem_usage}%"
    echo "    Disk Usage:       ${disk_usage}%"
    
    # Recommendations
    echo -e "\n  ${BOLD}Recommendations:${NC}"
    
    if (( $(echo "$cpu_usage > 80" | bc -l) )); then
        echo "    - CPU usage is high. Consider closing unnecessary processes."
    fi
    
    if (( $(echo "$mem_usage > 80" | bc -l) )); then
        echo "    - Memory usage is high. Consider freeing up RAM."
    fi
    
    if [ "$disk_usage" -gt 80 ]; then
        echo "    - Disk usage is high. Clean up unnecessary files."
    fi
    
    if [ "$health_score" -eq 100 ]; then
        echo -e "    ${GREEN}✓ System is running optimally!${NC}"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 14. EMAIL ALERT
# ═══════════════════════════════════════════════════════════════

send_email_alert() {
    echo -e "\n${BOLD}${GREEN}[14/14] EMAIL ALERT SYSTEM${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    
    if [ "$ENABLE_EMAIL_ALERT" == "yes" ]; then
        # Check if there are any alerts
        if [ -f "$ALERT_FILE" ] && [ -s "$ALERT_FILE" ]; then
            echo "  Sending email alert to $ADMIN_EMAIL..."
            
            # Create email body
            local email_subject="System Health Alert - $(hostname) - $(date '+%Y-%m-%d %H:%M:%S')"
            local email_body="System Health Monitoring Alert\n\nHostname: $(hostname)\nDate: $(date)\n\nAlerts:\n\n$(cat $ALERT_FILE)\n\nFull report attached."
            
            # Send email using mail command (requires mailutils or mailx)
            if command -v mail &> /dev/null; then
                echo -e "$email_body" | mail -s "$email_subject" "$ADMIN_EMAIL" -A "$REPORT_FILE"
                echo -e "  ${GREEN}✓ Email alert sent successfully${NC}"
            else
                echo -e "  ${YELLOW}⚠️  'mail' command not found. Install mailutils: sudo apt install mailutils${NC}"
                echo "  Alert details saved to: $ALERT_FILE"
            fi
        else
            echo -e "  ${GREEN}✓ No critical alerts to send${NC}"
        fi
    else
        echo "  Email alerts are disabled. Set ENABLE_EMAIL_ALERT='yes' to enable."
    fi
}

# ═══════════════════════════════════════════════════════════════
# GENERATE HTML REPORT
# ═══════════════════════════════════════════════════════════════

generate_html_report() {
    cat > "$HTML_REPORT" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>System Health Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        h2 { color: #34495e; margin-top: 30px; }
        .metric { background: #ecf0f1; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .critical { background: #e74c3c; color: white; }
        .warning { background: #f39c12; color: white; }
        .good { background: #27ae60; color: white; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #3498db; color: white; }
        .bar { height: 20px; background: #3498db; border-radius: 3px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🖥️ System Health Report</h1>
        <p><strong>Generated:</strong> $(date '+%Y-%m-%d %H:%M:%S')</p>
        <p><strong>Hostname:</strong> $(hostname)</p>
        
        <h2>System Summary</h2>
        <div class="metric">
            <p>CPU Usage: $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')%</p>
            <p>Memory Usage: $(free | awk 'NR==2{printf "%.2f", $3*100/$2}')%</p>
            <p>Disk Usage: $(df / | awk 'NR==2{print $5}')</p>
        </div>
        
        <h2>Full Report</h2>
        <p>See detailed text report: <a href="$(basename $REPORT_FILE)">$(basename $REPORT_FILE)</a></p>
        
        <p><em>Report generated by System Health Monitor</em></p>
    </div>
</body>
</html>
EOF
    
    echo -e "\n${GREEN}✓ HTML report generated: $HTML_REPORT${NC}"
}

# ═══════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════

main() {
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}Note: Some checks require root privileges. Run with sudo for complete monitoring.${NC}\n"
    fi
    
    # Start monitoring
    {
        print_banner
        
        check_system_info
        check_uptime
        check_cpu
        check_memory
        check_disk
        check_network
        check_processes
        check_users
        check_temperature
        check_battery
        check_security
        check_services
        generate_health_report
        send_email_alert
        
        # Summary
        echo -e "\n${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
        echo -e "${BOLD}${GREEN}MONITORING COMPLETE${NC}"
        echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
        echo -e "  Report saved to:      ${YELLOW}$REPORT_FILE${NC}"
        echo -e "  HTML report saved to: ${YELLOW}$HTML_REPORT${NC}"
        
        if [ -s "$ALERT_FILE" ]; then
            echo -e "  Alerts saved to:      ${RED}$ALERT_FILE${NC}"
        fi
        
        echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}\n"
        
    } | tee "$REPORT_FILE"
    
    # Generate HTML report
    generate_html_report
}

# Run main function
main

exit 0