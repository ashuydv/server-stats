#!/bin/bash

# ============================================================
#  server-stats.sh — Basic Server Performance Analyser
# ============================================================

BOLD="\e[1m"
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

divider() {
  echo -e "${CYAN}──────────────────────────────────────────────────────${RESET}"
}

header() {
  echo -e "\n${BOLD}${GREEN}$1${RESET}"
  divider
}

# ── Header ────────────────────────────────────────────────
clear
echo -e "${BOLD}${CYAN}"
echo "  ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ "
echo "  ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗"
echo "  ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝"
echo "  ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗"
echo "  ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║"
echo "  ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝"
echo -e "${RESET}${BOLD}              S T A T S   R E P O R T${RESET}"
echo -e "              $(date '+%Y-%m-%d %H:%M:%S %Z')\n"

# ── 1. OS & System Info ───────────────────────────────────
header "📋  SYSTEM INFORMATION"

OS=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
KERNEL=$(uname -r)
HOSTNAME=$(hostname)
ARCH=$(uname -m)
UPTIME=$(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | cut -d',' -f1-2)
LAST_BOOT=$(who -b 2>/dev/null | awk '{print $3, $4}')

printf "  %-18s %s\n" "Hostname:"    "$HOSTNAME"
printf "  %-18s %s\n" "OS:"          "${OS:-$(uname -s)}"
printf "  %-18s %s\n" "Kernel:"      "$KERNEL"
printf "  %-18s %s\n" "Architecture:" "$ARCH"
printf "  %-18s %s\n" "Uptime:"      "$UPTIME"
printf "  %-18s %s\n" "Last Boot:"   "${LAST_BOOT:-N/A}"

# ── 2. Load Average ───────────────────────────────────────
header "⚖️   LOAD AVERAGE"

LOAD=$(cat /proc/loadavg)
LOAD1=$(echo "$LOAD"  | awk '{print $1}')
LOAD5=$(echo "$LOAD"  | awk '{print $2}')
LOAD15=$(echo "$LOAD" | awk '{print $3}')
CPUS=$(nproc)

printf "  %-18s %s\n" "CPUs (logical):" "$CPUS"
printf "  %-18s %s  (5 min: %s)  (15 min: %s)\n" "Load (1 min):" "$LOAD1" "$LOAD5" "$LOAD15"

# ── 3. CPU Usage ──────────────────────────────────────────
header "🖥️   CPU USAGE"

# Read two snapshots to get accurate idle %
CPU_IDLE=$(top -bn2 | grep "Cpu(s)" | tail -1 | awk '{
  for(i=1;i<=NF;i++) {
    if($i ~ /^[0-9.]+,?$/ && $(i+1) ~ /^id/) { gsub(/,/,"",$i); print $i; exit }
    if($i ~ /[0-9.]+.id/) { match($i,/[0-9.]+/); print substr($i,RSTART,RLENGTH); exit }
  }
}')
CPU_IDLE=${CPU_IDLE:-$(vmstat 1 2 | tail -1 | awk '{print $15}')}
CPU_USED=$(awk "BEGIN {printf \"%.1f\", 100 - ${CPU_IDLE}}")

# Simple bar
BAR_LEN=40
FILLED=$(awk "BEGIN {printf \"%d\", (${CPU_USED}/100)*${BAR_LEN}}")
EMPTY=$(( BAR_LEN - FILLED ))
BAR=$(printf "%${FILLED}s" | tr ' ' '█')$(printf "%${EMPTY}s" | tr ' ' '░')

if   awk "BEGIN{exit !(${CPU_USED} >= 80)}"; then COLOR=$RED
elif awk "BEGIN{exit !(${CPU_USED} >= 50)}"; then COLOR=$YELLOW
else COLOR=$GREEN; fi

printf "  Total CPU Used:  ${COLOR}${BOLD}%s%%${RESET}\n" "$CPU_USED"
printf "  [${COLOR}%s${RESET}] %s%% used / %s%% idle\n" "$BAR" "$CPU_USED" "$CPU_IDLE"

# ── 4. Memory Usage ───────────────────────────────────────
header "🧠  MEMORY USAGE"

MEM_TOTAL=$(awk '/^MemTotal/ {print $2}' /proc/meminfo)
MEM_AVAIL=$(awk '/^MemAvailable/ {print $2}' /proc/meminfo)
MEM_FREE=$(awk  '/^MemFree/  {print $2}' /proc/meminfo)
MEM_USED=$(( MEM_TOTAL - MEM_AVAIL ))
MEM_PCT=$(awk "BEGIN {printf \"%.1f\", (${MEM_USED}/${MEM_TOTAL})*100}")

to_human() {
  local kb=$1
  if   [ "$kb" -ge 1048576 ]; then awk "BEGIN {printf \"%.2f GiB\", ${kb}/1048576}"
  elif [ "$kb" -ge 1024 ];     then awk "BEGIN {printf \"%.1f MiB\", ${kb}/1024}"
  else echo "${kb} KiB"; fi
}

FILLED=$(awk "BEGIN {printf \"%d\", (${MEM_PCT}/100)*${BAR_LEN}}")
EMPTY=$(( BAR_LEN - FILLED ))
BAR=$(printf "%${FILLED}s" | tr ' ' '█')$(printf "%${EMPTY}s" | tr ' ' '░')

if   awk "BEGIN{exit !(${MEM_PCT} >= 80)}"; then COLOR=$RED
elif awk "BEGIN{exit !(${MEM_PCT} >= 60)}"; then COLOR=$YELLOW
else COLOR=$GREEN; fi

printf "  %-12s %s\n" "Total:"     "$(to_human $MEM_TOTAL)"
printf "  %-12s %s\n" "Used:"      "$(to_human $MEM_USED)"
printf "  %-12s %s\n" "Available:" "$(to_human $MEM_AVAIL)"
printf "  [${COLOR}%s${RESET}] ${COLOR}${BOLD}%s%%${RESET} used\n" "$BAR" "$MEM_PCT"

# Swap
SWAP_TOTAL=$(awk '/^SwapTotal/ {print $2}' /proc/meminfo)
SWAP_FREE=$(awk  '/^SwapFree/  {print $2}' /proc/meminfo)
SWAP_USED=$(( SWAP_TOTAL - SWAP_FREE ))
if [ "$SWAP_TOTAL" -gt 0 ]; then
  SWAP_PCT=$(awk "BEGIN {printf \"%.1f\", (${SWAP_USED}/${SWAP_TOTAL})*100}")
  printf "  Swap: %s used / %s total (%s%%)\n" \
    "$(to_human $SWAP_USED)" "$(to_human $SWAP_TOTAL)" "$SWAP_PCT"
else
  echo "  Swap: not configured"
fi

# ── 5. Disk Usage ─────────────────────────────────────────
header "💾  DISK USAGE"

printf "  %-20s %8s %8s %8s %6s\n" "Filesystem" "Size" "Used" "Avail" "Use%"
divider
df -h --output=source,size,used,avail,pcent -x tmpfs -x devtmpfs -x squashfs 2>/dev/null \
  | tail -n +2 \
  | while IFS= read -r line; do
      PCT=$(echo "$line" | awk '{gsub(/%/,"",$5); print $5}')
      if   [ "${PCT:-0}" -ge 90 ]; then C=$RED
      elif [ "${PCT:-0}" -ge 70 ]; then C=$YELLOW
      else C=$GREEN; fi
      FS=$(echo "$line"   | awk '{print $1}')
      SIZE=$(echo "$line" | awk '{print $2}')
      USED=$(echo "$line" | awk '{print $3}')
      AVAIL=$(echo "$line"| awk '{print $4}')
      printf "  %-20s %8s %8s %8s ${C}%5s%%${RESET}\n" "$FS" "$SIZE" "$USED" "$AVAIL" "$PCT"
    done

# ── 6. Top 5 Processes by CPU ─────────────────────────────
header "🔥  TOP 5 PROCESSES BY CPU"

printf "  %-8s %-10s %8s %8s  %s\n" "PID" "USER" "CPU%" "MEM%" "COMMAND"
divider
ps aux --sort=-%cpu 2>/dev/null | awk 'NR>1 {
  printf "  %-8s %-10s %8s %8s  %s\n", $2, $1, $3, $4, $11
}' | head -5

# ── 7. Top 5 Processes by Memory ──────────────────────────
header "🧩  TOP 5 PROCESSES BY MEMORY"

printf "  %-8s %-10s %8s %8s  %s\n" "PID" "USER" "MEM%" "CPU%" "COMMAND"
divider
ps aux --sort=-%mem 2>/dev/null | awk 'NR>1 {
  printf "  %-8s %-10s %8s %8s  %s\n", $2, $1, $4, $3, $11
}' | head -5

# ── 8. Logged-In Users ────────────────────────────────────
header "👥  LOGGED-IN USERS"

USERS=$(who 2>/dev/null)
if [ -n "$USERS" ]; then
  printf "  %-12s %-10s %-16s %s\n" "USER" "TTY" "FROM" "LOGIN TIME"
  divider
  echo "$USERS" | awk '{printf "  %-12s %-10s %-16s %s %s\n", $1, $2, ($5 ? $5 : "-"), $3, $4}'
else
  echo "  No users currently logged in."
fi

# ── 9. Failed Login Attempts ──────────────────────────────
header "🚨  FAILED LOGIN ATTEMPTS (last 10)"

if [ -f /var/log/auth.log ]; then
  FAILS=$(grep "Failed password" /var/log/auth.log 2>/dev/null | tail -10)
elif [ -f /var/log/secure ]; then
  FAILS=$(grep "Failed password" /var/log/secure 2>/dev/null | tail -10)
else
  FAILS=""
fi

if [ -n "$FAILS" ]; then
  echo "$FAILS" | while IFS= read -r line; do
    echo "  $line"
  done
  TOTAL=$(echo "$FAILS" | wc -l)
  echo -e "\n  ${RED}${BOLD}Showing last 10 failed attempts.${RESET}"
else
  # Try journalctl as fallback
  if command -v journalctl &>/dev/null; then
    FAILS=$(journalctl _SYSTEMD_UNIT=sshd.service 2>/dev/null | grep "Failed password" | tail -10)
    if [ -n "$FAILS" ]; then
      echo "$FAILS" | while IFS= read -r line; do echo "  $line"; done
    else
      echo "  No failed login attempts found (or insufficient permissions)."
    fi
  else
    echo "  No failed login attempts found (or insufficient permissions)."
  fi
fi

# ── Footer ────────────────────────────────────────────────
divider
echo -e "  ${BOLD}Report generated:${RESET} $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "  ${BOLD}Hostname:${RESET}         $(hostname)"
divider
echo ""
