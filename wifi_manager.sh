#!/data/data/com.termux/files/usr/bin/bash

# ======================================================
# wifi_manager.sh untuk Qualcomm qcacld (tanpa vinf)
# Mode monitor via con_mode sysfs, restart driver untuk reset
# ======================================================

MODULE_PATH="/data/local/tmp/wlan.ko"
INTERFACE="wlan0"
CON_MODE_PATH="/sys/module/wlan/parameters/con_mode"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[ERROR]${NC} Need to run as root. Use 'su' or 'sudo'."
        exit 1
    fi
}

check_deps() {
    for cmd in iw ip svc; do
        if ! command -v $cmd &>/dev/null; then
            echo -e "${RED}[ERROR]${NC} '$cmd' is required but not found. Please install it."
            exit 1
        fi
    done
}

# Restart driver (reload modul)
restart_driver() {
    echo -ne "${YELLOW}[INFO]${NC} Reload driver wlan..."
    svc wifi disable 2>/dev/null
    ip link set "$INTERFACE" down 2>/dev/null
    sleep 1
    if [[ -f "$MODULE_PATH" ]]; then
        rmmod wlan 2>/dev/null
        insmod "$MODULE_PATH"
        if [[ $? -eq 0 ]]; then
            svc wifi enable 2>/dev/null
            echo -e " ${GREEN}done${NC}"
            return 0
        else
            echo -e " ${RED}failed${NC}"
            return 1
        fi
    else
        echo -e " ${RED}module not found${NC}"
        return 1
    fi
}

# Set mode: managed (0) atau monitor (4) via con_mode
# Untuk monitor langsung pakai con_mode=4, untuk managed set 0 lalu restart driver (karena qcacld butuh reload)
set_mode() {
    local mode="$1"
    if [[ ! "$mode" =~ ^(managed|monitor)$ ]]; then
        echo -e "${RED}[ERROR]${NC} Must specify mode: 'managed' or 'monitor'."
        return 1
    fi

    if [[ ! -f "$CON_MODE_PATH" ]]; then
        echo -e "${RED}[ERROR]${NC} con_mode not found. Driver might not be qcacld."
        return 1
    fi

    local current=$(cat "$CON_MODE_PATH" 2>/dev/null | tr -d ' \n')
    if [[ "$mode" == "monitor" ]]; then
        if [[ "$current" == "4" ]]; then
            echo -e "${YELLOW}[INFO]${NC} Already in monitor mode."
            return 0
        fi
        echo -ne "${YELLOW}[INFO]${NC} Switching to monitor mode..."
        svc wifi disable 2>/dev/null
        ip link set "$INTERFACE" down 2>/dev/null
        echo "4" > "$CON_MODE_PATH" 2>/dev/null
        sleep 1
        ip link set "$INTERFACE" up 2>/dev/null
        echo -e " ${GREEN}done${NC}"
    else
        # managed: butuh restart driver setelah set con_mode 0
        if [[ "$current" == "0" ]]; then
            echo -e "${YELLOW}[INFO]${NC} Already in managed mode."
            return 0
        fi
        echo -ne "${YELLOW}[INFO]${NC} Switching to managed mode (restart driver)..."
        # echo "0" > "$CON_MODE_PATH" 2>/dev/null
        sleep 1
        # Restart driver biar bersih
        rmmod wlan 2>/dev/null
        insmod "$MODULE_PATH" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            svc wifi enable 2>/dev/null
            echo -e " ${GREEN}done${NC}"
        else
            echo -e " ${RED}failed reload module${NC}"
            return 1
        fi
    fi
    return 0
}

# Set channel pada interface monitor (wlan0 harus dalam monitor mode)
set_channel() {
    local chan="$1"
    if [[ -z "$chan" ]]; then
        echo -e "${RED}[ERROR]${NC} Specify channel."
        return 1
    fi
    local mode=$(iw dev "$INTERFACE" info 2>/dev/null | grep type | awk '{print $2}')
    if [[ "$mode" != "monitor" ]]; then
        echo -e "${RED}[ERROR]${NC} $INTERFACE is not in monitor mode. Run 'mode monitor' first."
        return 1
    fi
    echo -e "${YELLOW}[INFO]${NC} Setting channel $chan on $INTERFACE..."
    iw dev "$INTERFACE" set channel "$chan"
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC} Channel $chan."
    else
        echo -e "${RED}[ERROR]${NC} Failed to set channel."
        return 1
    fi
}

# Status
show_status() {
    echo "========== WiFi Status (qcacld) =========="
    lsmod | grep -q "^wlan" && echo -e "Driver wlan    : ${GREEN}loaded${NC}" || echo -e "Driver wlan    : ${RED}not loaded${NC}"
    if [[ -f "$CON_MODE_PATH" ]]; then
        local con_val=$(cat "$CON_MODE_PATH" 2>/dev/null | tr -d ' \n')
        echo "con_mode       : ${con_val:-N/A} (0=managed, 4=monitor)"
    fi
    local state=$(ip link show "$INTERFACE" 2>/dev/null | grep -o "state [A-Z]*" | awk '{print $2}')
    local mode=$(iw dev "$INTERFACE" info 2>/dev/null | grep type | awk '{print $2}')
    echo "Interface $INTERFACE : state=${state:-down}, mode=${mode:-unknown}"
    if [[ "$mode" == "monitor" ]]; then
        local chan=$(iw dev "$INTERFACE" info 2>/dev/null | grep channel | awk '{print $2}')
        echo "Channel        : ${chan:-N/A}"
    fi
    echo "=========================================="
}

usage() {
    cat << EOF
Usage: $(basename $0) {restart|mode|channel|status} [args]

  restart                     Restart driver (reload module wlan.ko)
  mode {managed|monitor}      Set mode via con_mode
  channel <chan>              Set channel (just for monitor mode)
  status                      Show status

Example:
  $(basename $0) mode monitor
  $(basename $0) channel 6
  $(basename $0) mode managed   -> Automatically restart driver
  $(basename $0) restart
  $(basename $0) status
EOF
    exit 1
}

# Main
check_root
check_deps

ACTION="$1"
case "$ACTION" in
    restart) restart_driver ;;
    mode)    set_mode "$2" ;;
    channel) set_channel "$2" ;;
    status)  show_status ;;
    *)       usage ;;
esac

exit 0
