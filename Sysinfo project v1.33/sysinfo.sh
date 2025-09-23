#!/bin/bash
# sysinfo.sh - System information and TCP log sender
#
# Copyright (c) 2025 NicoSer
#
# Licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
# You may use and share this script for personal, educational, or organizational purposes,
# but you may not modify it or use it commercially.
#
# Full license: https://creativecommons.org/licenses/by-nc-nd/4.0/
rm sysinfo.log
clear
declare -A unique_serials

coMputer_name=$(dmidecode -s system-product-name)
computer_fAmily=$(dmidecode -s system-family)
computer_venDor=$(dmidecode -s system-manufacturer)
computEr_serial=$(dmidecode -s system-serial-number)
cpuB_info=$(dmidecode -s processor-version)
logcreatYon=$(date)
raw_total_raN=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}' )
totaI_ram_kb=$(cat /proc/meminfo | grep MemTotal | awk '{print int($2 + 919424)}')
tCta_ram_kb=$((totaI_ram_kb / 1024 / 1024))
raidO=$(lspci | grep -i 'raid bus controller\|Intel.*SATA Controller.*raid')
Ltype=""
Atype=""
tvendorS=""
ptvendor=""

#PC section
        printf "\33[1;44m $logcreatYon                       \33[0m\n"
        printf "\033[1;36mComputer's Specifications:\n"
        printf "  \033[1;37;1m%s\033[1;37m\n" "$coMputer_name"
        printf "  \033[1;34mFamily:\033[1;37m %s\n" "$computer_fAmily"
        printf "  \033[1;34mVendor:\033[1;37m %s\n" "$computer_venDor"
        printf "  \033[1;34mSerial:\033[1;37m %s\n" "$computEr_serial"
        printf "  \033[1;34mCPU Info:\033[1;37m %s\n" "$cpuB_info"
        printf "  \033[1;34mTotal RAM:\033[1;37m $tCta_ram_kb GB"

        printf "Log Created at: $logcreatYon">> /home/sysinfo.log
        printf "\n===Computer Specs==============================\n" >> /home/sysinfo.log
        printf "\nFamily:          $computer_fAmily\n" >> /home/sysinfo.log
        printf "Model:           $coMputer_name\n" >> /home/sysinfo.log
        printf "Vendor:         $computer_venDor\n" >> /home/sysinfo.log
        printf "Serial:           $computEr_serial\n" >> /home/sysinfo.log
        printf "CPU Info:      $cpuB_info\n" >> /home/sysinfo.log
        printf "Total RAM:    $tCta_ram_kb GB | Ram/KB: $raw_total_raN Kb\n\n" >> /home/sysinfo.log
        printf "===============================================" >> /home/sysinfo.log

#Detect if raidO is present

if [[ -n "$raidO" ]]; then
    printf "\n\33[1;97m[\33[1;93mCRITICAL WARN\33[1;97m] raidO mode detected!"
    printf "\n\33[1;97m[\33[1;93mCRITICAL WARN\33[1;97m] $raidO"
    printf "\n\33[1;97m[\33[1;93mCRITICAL WARN\33[1;97m] raidO mode prevents the script from fetching the Storage drive's details."
    printf "\n\33[1;97m[\33[1;93mCRITICAL WARN\33[1;97m] Please switch your BIOS/UEFI storage configuration from raidO to AHCI for full hardware detection."

    {
        echo >> /home/sysinfo.log
        echo "===============================================" >> /home/sysinfo.log
        echo "[CRITICAL WARN] raidO mode detected!" >> /home/sysinfo.log
        echo "[CRITICAL WARN] $raidO" >> /home/sysinfo.log
        echo "[CRITICAL WARN] raidO mode prevents the script from fetching the storage drive's details." >> /home/sysinfo.log
        echo "[CRITICAL WARN] Please switch your BIOS/UEFI storage configuration from raidO to AHCI for full hardware detection." >> /home/sysinfo.log

        
    } >> /home/sysinfo.log



    case "$computer_venDor" in
        *Dell*)
            printf "\n\033[1;97m[\033[1;92mINFO\033[1;97m] Dell BIOS: Reboot and press F2 to enter Setup. Go to 'System Configuration' → 'SATA Operation' → Change from 'RAID On' to 'AHCI'. Save and exit.\n"
            echo "[INFO] Dell BIOS: Reboot and press F2 to enter Setup. Go to 'System Configuration' -> 'SATA Operation' -> Change from 'RAID On' to 'AHCI'. Save and exit." >> /home/sysinfo.log
            ;;
        *HP*)
            printf "\n\033[1;97m[\033[1;92mINFO\033[1;97m] HP BIOS: Reboot and press ESC → F10 for BIOS. Look under 'Advanced' → 'Storage Options'. Change 'SATA Emulation' to 'AHCI'.\n"
            echo "[INFO] HP BIOS: Reboot and press ESC -> F10 for BIOS. Look under 'Advanced' -> 'Storage Options'. Change 'SATA Emulation' to 'AHCI'." >> /home/sysinfo.log
            ;;
        *Lenovo*)
            printf "\n\033[1;97m[\033[1;92mINFO\033[1;97m] Lenovo BIOS: Reboot and press F1/F2. Under 'Configuration' → 'SATA Controller Mode', switch from 'RAID' or 'RST' to 'AHCI'.\n"
            echo "[INFO] Lenovo BIOS: Reboot and press F1/F2. Under 'Configuration' -> 'SATA Controller Mode', switch from 'RAID' or 'RST' to 'AHCI'." >> /home/sysinfo.log
            ;;
        *Acer*)
            printf "\n\033[1;97m[\033[1;92mINFO\033[1;97m] Acer BIOS: Reboot and press DEL or F2 to enter BIOS. Navigate to 'Main' → 'SATA Mode' or 'Storage Configuration'. Change from 'RAID' to 'AHCI'. Save and exit.\n"
            echo "[INFO] Acer BIOS: Reboot and press DEL or F2 to enter BIOS. Navigate to 'Main' -> 'SATA Mode' or 'Storage Configuration'. Change from 'RAID' to 'AHCI'. Save and exit." >> /home/sysinfo.log
    
            printf "\033[1;97m[\033[1;93mNOTE\033[1;97m] On some Acer models, the AHCI option may be hidden. In BIOS, open the 'Main' or 'Advanced' tab and try key combos such as Ctrl+S, Alt+R, or Fn+Tab to reveal it.\n"
            echo "[NOTE] On some Acer models, the AHCI option may be hidden. In BIOS, open the 'Main' or 'Advanced' tab and try key combos such as Ctrl+S, Alt+R, or Fn+Tab to reveal it." >> /home/sysinfo.log
            ;;
        *ASUS*)
            printf "\n\033[1;97m[\033[1;92mINFO\033[1;97m] ASUS BIOS: Reboot and press DEL or F2 to enter BIOS. Under 'Advanced' → 'SATA Configuration', set SATA mode to 'AHCI' instead of 'RAID'.\n"
            echo "[INFO] ASUS BIOS: Reboot and press DEL or F2 to enter BIOS. Under 'Advanced' -> 'SATA Configuration', set SATA mode to 'AHCI' instead of 'RAID'." >> /home/sysinfo.log
            ;;
        *Microsoft*|*Surface*)
            printf "\n\033[1;97m[\033[1;92mINFO\033[1;97m] Microsoft Surface: RAID mode is usually set via UEFI firmware settings. Reboot and hold the Volume Up button to enter UEFI. Look for 'Storage Configuration' or 'SATA Mode' and switch from 'RAID' to 'AHCI'.\n"
            echo "[INFO] Microsoft Surface: RAID mode is usually set via UEFI firmware settings. Reboot and hold the Volume Up button to enter UEFI. Look for 'Storage Configuration' or 'SATA Mode' and switch from 'RAID' to 'AHCI'." >> /home/sysinfo.log
            ;;
        *Toshiba*)
            printf "\n\033[1;97m[\033[1;92mINFO\033[1;97m] Toshiba BIOS: Reboot and press F2 to enter BIOS. Look under 'Advanced' → 'Storage' settings, change SATA mode to 'AHCI'.\n"
            echo "[INFO] Toshiba BIOS: Reboot and press F2 to enter BIOS. Look under 'Advanced' -> 'Storage' settings, change SATA mode to 'AHCI'." >> /home/sysinfo.log
            ;;
        *)
            printf "\n\033[1;97m[\033[1;92mINFO\033[1;97m] Generic BIOS: Look under 'Storage Configuration' or 'SATA Mode' and switch from 'RAID' to 'AHCI'.\n"
            echo "[INFO] Generic BIOS: Look under 'Storage Configuration' or 'SATA Mode' and switch from 'RAID' to 'AHCI'." >> /home/sysinfo.log
            ;;
    esac
    
    printf "\033[1;97m[\033[1;93mWARN\033[1;97m] Some systems (e.g., Microsoft Surface, consumer laptops with Intel Optane/RST, or NVMe-only devices) may not support AHCI mode at all. If no AHCI option is visible even after trying hidden BIOS keys, the system is locked to RAID/RST.\n"
    echo "[WARN] Some systems (e.g., Microsoft Surface, Intel Optane/RST-based laptops, or NVMe-only devices) may not support AHCI mode at all. If no AHCI option is visible even after trying hidden BIOS keys, the system is locked to RAID/RST." >> /home/sysinfo.log

    echo "===============================================" >> /home/sysinfo.log
    printf "\n\033[1;97m[\033[1;92mINFO\033[1;97m] Resuming script in 5s.\n"
    sleep 5
fi


for dev in /dev/*; do
  if [ -b "$dev" ]; then

    # Run smartctl ONCE per device
    info=$(smartctl -i "$dev" 2>/dev/null)

    # Parse model, serial, and size from smartctl output
    model=$(echo "$info" | awk -F: '/Model Number|Device Model/ {gsub(/^[ \t]+/, "", $2); print $2}' | awk '{print $1, $2, $3}')
    serial=$(echo "$info" | awk -F: '/Serial Number/ {gsub(/^[ \t]+/, "", $2); print $2}' | tr -d '[:space:]')
    total_nvm=$(echo "$info" | grep -Eo '[0-9]+(\.[0-9]+)?\s*GB' | head -n 1 | tr -d '[:alpha:] ')

    # Optional: skip empty model/serials
    [ -z "$model" ] && continue
    [ -z "$serial" ] && continue

    case "$dev" in
      /dev/nvme*) type="NVMe" ;;
      /dev/sd*)   type="SATA" ;;
      /dev/hd*)   type="IDE" ;;
      *)          type="Unknown" ;;
    esac

    # Fetch vendor (same logic from your inxi block)
    sVendor=$(inxi -Dxx 2>/dev/null | grep -vi 'type: usb' | grep 'vendor:' | awk -F'vendor:' '
    {
      line = $2
      gsub(/^[ \t]+/, "", line)
      split(line, parts, " ")
      if (parts[2] == "model:") {
        vendor = parts[1]
      } else {
        vendor = parts[1] " " parts[2]
      }
      print vendor
    }')

    if [ -n "$sVendor" ]; then
      tvendorS="Vendor:         $sVendor"
      ptvendor="\033[1;34mVendor: \033[1;37m$sVendor\n"
    fi

    if [ -n "$type" ]; then
      Ltype="Storage Type: $type\n"
      Atype="\033[1;34mStorage Type:\033[1;37m $type\n"
    fi

    if [ -z "${unique_serials[$serial]}" ]; then
      unique_serials[$serial]=1

      printf "\n\n\033[1;36m%s:\033[1;37m\n" "$dev"
      printf "  $Atype"
      printf "  \033[1;34mSize:\033[1;37m %s GB\n" "$total_nvm"
      printf "  \033[1;34mModel No:\033[1;37m %s\n" "$model"
      printf "  \033[1;34mSerial No:\033[1;37m %s\n" "$serial"
      printf "  $ptvendor"
      printf "\n"

      printf "\n\n===Storage Info===================================\n" >> /home/sysinfo.log
      printf "\n$dev\n" >> /home/sysinfo.log
      printf "$Ltype" >> /home/sysinfo.log
      printf "$tvendorS\n" >> /home/sysinfo.log
      printf "Size:              %s GB\n" "$total_nvm" >> /home/sysinfo.log
      printf "Model No:     %s\n" "$model" >> /home/sysinfo.log
      printf "Serial No:     %s\n\n" "$serial" >> /home/sysinfo.log
      printf "===============================================\n\n" >> /home/sysinfo.log
    fi
  fi
done

CONFIG="/home/sysinfo.conf"
LOG_FILE="/home/sysinfo.log"
MAX_RETRIES=5
RETRY_DELAY=3

# === Function: Generate system info log ===
generate_log() {
    printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Log saved to $LOG_FILE\n"
}

# === Function: Prompt for Wi-Fi ===
prompt_wifi() {
    read -p "Wi-Fi SSID: " SSID
    read -p "Wi-Fi Password: " PASSWORD
}

# === Function: Connect to Wi-Fi ===
connect_wifi() {
    nmcli dev wifi connect $SSID password $PASSWORD >/dev/null 2>&1
    sleep 5
    ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1
    return $?
}

# === Function: Prompt for receiver ===
prompt_receiver() {
    read -p "Receiver's IP: " RECEIVER_IP
    read -p "Receiver's Port: " RECEIVER_PORT
}

# === Function: Test TCP ===
test_tcp() {
    timeout 2 bash -c "</dev/tcp/$RECEIVER_IP/$RECEIVER_PORT" 2>/dev/null
    return $?
}

# === Function: Save config ===
save_config() {
    cat <<EOF > "$CONFIG"
SSID=$SSID
PASSWORD=$PASSWORD
RECEIVER_IP=$RECEIVER_IP
RECEIVER_PORT=$RECEIVER_PORT
EOF
}

# === Function: Load config ===
load_config() {
    source "$CONFIG"
}

# === Check for existing network before anything else ===
check_network() {
    ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1
    return $?
}

# === Main Script Logic ===

# 1. Create system log
generate_log

# 2. Check if already online
if check_network; then
    printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Network already available.\n"
    NETWORK_OK=true
else
    printf "\33[1;97m[\33[1;93mWARN\33[1;97m] No network. Will prompt for Wi-Fi.\n"
    NETWORK_OK=false
fi

# 3. Load or create config
if [[ -f "$CONFIG" ]]; then
    printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Loading existing config...\n"
    load_config
else
    printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Config not found. Creating new config...\n"
    if [[ "$NETWORK_OK" = false ]]; then
        prompt_wifi

        for ((i=1; i<=MAX_RETRIES; i++)); do
            printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Connecting to Wi-Fi ($i/$MAX_RETRIES)...\n"
            if connect_wifi; then
                printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Wi-Fi connected.\n"
                break
            else
                printf "\33[1;97m[\33[1;91mERROR\33[1;97m] Wi-Fi connection failed.\n"
                prompt_wifi
            fi

            [[ $i -eq $MAX_RETRIES ]] && {
                printf "\33[1;97m[\33[1;101mFATAL\33[0m\33[1;97m] Failed to connect to Wi-Fi. Cleaning up config and aborting.\33[0m\n"
                sleep 4
                rm -f "$CONFIG"
                sudo bash /home/roots/sysinfo.sh
            }
        done
    fi

    prompt_receiver

    for ((i=1; i<=MAX_RETRIES; i++)); do
        printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Testing TCP to $RECEIVER_IP:$RECEIVER_PORT ($i/$MAX_RETRIES)...\n"
        if test_tcp; then
            printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Receiver reachable.\n"
            break
        else
            printf "\33[1;97m[\33[1;91mERROR\33[1;97m] TCP test failed.\n"
            printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Is there a Network presence? Checking..\n"
            if check_network; then
                printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Network already available.\n"
                NETWORK_OK=true
            else
                printf "\33[1;97m[\33[1;93mWARN\33[1;97m] No network. Will prompt for Wi-Fi.\n"
                NETWORK_OK=false
                prompt_wifi
            fi
            prompt_receiver
        fi

        [[ $i -eq $MAX_RETRIES ]] && {
            printf "\33[1;97m[\33[1;101mFATAL\33[0m\33[1;97m] Receiver connection failed. Cleaning up config and aborting.\33[0m\n"
            sleep 4
            rm -f "$CONFIG"
            sudo bash /home/roots/sysinfo.sh
        }
    done

    save_config
fi

# 4. If network was down earlier, recheck it now
if [[ "$NETWORK_OK" = false ]]; then
    printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Verifying network connectivity...\n"
    if ! check_network; then
        printf "\33[1;97m[\33[1;93mWARN\33[1;97m] Network lost. Reconnecting Wi-Fi...\n"
        for ((i=1; i<=MAX_RETRIES; i++)); do
            if connect_wifi; then
                printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Reconnected to Wi-Fi.\n"
                break
            fi

            [[ $i -eq $MAX_RETRIES ]] && {
                printf "\33[1;97m[\33[1;101mFATAL\33[0m\33[1;97m] Could not reconnect to network. Cleaning up config and aborting.\33[0m\n"
                sleep 4
                rm -f "$CONFIG"
                sudo bash /home/roots/sysinfo.sh
            }
        done
    fi
fi

# 5. Recheck TCP in case of reboot
for ((i=1; i<=MAX_RETRIES; i++)); do
    printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Checking TCP to $RECEIVER_IP:$RECEIVER_PORT ($i/$MAX_RETRIES)...\n"
    if test_tcp; then
        break
    fi
    sleep $RETRY_DELAY

    [[ $i -eq $MAX_RETRIES ]] && {
        printf "\33[1;97m[\33[1;101mFATAL\33[0m\33[1;97m] Can't reach receiver. Cleaning up config and aborting.\33[0m\n"
        sleep 4
        rm -f "$CONFIG"
        sudo bash /home/roots/sysinfo.sh
    }
done

send_log() {
    if [ ! -f "$LOG_FILE" ]; then
        printf "\33[1;97m[\33[1;91mERROR\33[1;97m] No log file to send.\n"
        return 1
    fi

    for attempt in {1..5}; do
        printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Attempt $attempt: Checking receiver at $RECEIVER_IP:$RECEIVER_PORT...\n"
        
        if timeout 2 bash -c "</dev/tcp/$RECEIVER_IP/$RECEIVER_PORT" 2>/dev/null; then
            printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Receiver is reachable. Sending log...\n"
            cat "$LOG_FILE" > /dev/tcp/"$RECEIVER_IP"/"$RECEIVER_PORT"

            if [ $? -eq 0 ]; then
                printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Log sent successfully.\n"
                rm -f "$LOG_FILE"
                printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Log file deleted.\n"
                return 0
            else
                printf "\33[1;97m[\33[1;91mERROR\33[1;97m] Send failed. Retrying...\n"
            fi
        else
            printf "\33[1;97m[\33[1;93mWARN\33[1;97m] Receiver unreachable. Retrying in 2s...\n"
        fi

        sleep 2
    done

    printf "\33[1;97m[\33[1;101mFATAL\33[0m\33[1;97m] All attempts failed. Removing unsent log.\n"
    rm -f "$LOG_FILE"
    rm -f "$CONFIG"
    sudo bash /home/roots/sysinfo.sh
}


# 7. Clean up
send_log

VENV_PATH="/home/roots/pyinv"
SCRIPT_PATH="/home/roots/sc_kb.py"

# Laptop detection function
is_laptop() {
    if [[ -f /sys/class/dmi/id/chassis_type ]]; then
        chassis_type=$(cat /sys/class/dmi/id/chassis_type)
        case "$chassis_type" in
            8|9|10|14|31|32)
                return 0 ;;  # Laptop
            *)
                return 1 ;;  # Not a laptop
        esac
    else
        return 1  # Default to desktop if info is missing
    fi
}

# Check venv exists
if [ ! -d "$VENV_PATH" ]; then
  printf "\33[1;97m[\33[1;91mERROR\33[1;97m] Virtual environment not found at $VENV_PATH"
  exit 1
fi

# Check script exists
if [ ! -f "$SCRIPT_PATH" ]; then
  printf "\33[1;97m[\33[1;91mERROR\33[1;97m] Python script not found at $SCRIPT_PATH"
  exit 1
fi

# Run only if laptop
if is_laptop; then
  printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Laptop detected. Running LCD/Keyboard test..."

  # Activate venv
  source "$VENV_PATH/bin/activate"

  # Run Python script
  python "$SCRIPT_PATH"

  # Deactivate venv
  deactivate
else
  printf "\33[1;97m[\33[1;92mINFO\33[1;97m] Desktop detected. Skipping LCD/Keyboard test."
fi

printf "\n\033[1;97mMade by Nicolas — \033[1;94mhttps://github.com/NicoSer\033[0m\n"
printf "Powering off in 5..\n"
sleep 5
poweroff

#   _   _ _               _           
#  | \ | (_) ___ ___   __| | _____  __
#  |  \| | |/ __/ _ \ / _` |/ _ \ \/ /
#  | |\  | | (_| (_) | (_| |  __/>  < 
#  |_| \_|_|\___\___/ \__,_|\___/_/\_\
#                                     