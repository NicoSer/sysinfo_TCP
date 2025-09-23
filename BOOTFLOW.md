# Sysinfo Boot Flow

This document explains the boot workflow of the `sysinfo.img` environment.

---

## 1. Boot
- Insert the `sysinfo.img` USB.  
- System boots into a **stripped-down Ubuntu Server 24.04.3 LTS**.  
- Only essential packages are present → faster boot, fewer services.  
- Secure Boot supported.  

---

## 2. Auto Login
- Auto-login occurs as the **roots** user.  
- No manual credentials needed.  
- Console-only (no desktop environment).  

---

## 3. Script Launch
- On login, **`sysinfo.sh`** launches automatically.  
- The terminal session is locked into the script (user not dropped to shell unless debug/recovery steps are used).  

---

## 4. Network Check
- `sysinfo.sh` checks for active internet connection.  
- If no network is found:  
  - Prompts for Wi-Fi SSID + password.  
  - Uses **nmcli** (NetworkManager CLI) to configure the connection.  
  - Saves credentials → no re-prompt on next boot.  

---

## 5. System Information Collection
- Hardware info gathered with:  
  - `dmidecode` (system vendor, product, family, serial, CPU)  
  - `lspci` (controllers, RAID detection)  
  - `inxi` (detailed summary)  
  - `smartctl` (disk health, if applicable)  
- **RAID failsafe:**  
  - Detects if system is in RAID mode.  
  - Provides **vendor-specific BIOS/UEFI instructions** to switch to AHCI.  
  - Adds RAID guidance into the generated log.  

---

## 6. Device Type Check
- **Laptop/Tablet** → runs `sc_kb.py`:  
  - Fullscreen color tests.  
  - Vintage TV pattern.  
  - Keyboard test (ESC ×5 = skip).  
- **Tower/Desktop** → skips `sc_kb.py`.  

---

## 7. Log Transmission
- Generates `sysinfo.log`.  
- Sends log via **plain TCP** to configured **Receiver IP:Port**.  
- Includes RAID warning if applicable.  

---

## 8. Cleanup & Poweroff
- After transmission is confirmed:  
  - Deletes `sysinfo.log`.  
  - Powers off the system.  

---

## 🔁 Recovery / Manual Re-Run
If the script is accidentally interrupted (user exits to shell):  

1. Enter root shell:  
   ```bash
   sudo -s
   # Password: 1

   


┌───────────────────────┐
│   Insert USB (sysinfo.img)  
│   Boot into stripped Ubuntu  
└───────────────┬───────┘
                │
                ▼
┌───────────────────────┐
│   Auto-login as "roots"  
│   sysinfo.sh starts automatically  
└───────────────┬───────┘
                │
                ▼
┌───────────────────────┐
│   Network Check  
│   ├─ Connected → continue  
│   └─ Not connected → prompt SSID/password (nmcli)  
└───────────────┬───────┘
                │
                ▼
┌───────────────────────┐
│   Collect System Info  
│   - dmidecode / lspci / inxi / smartctl  
│   - RAID detection + vendor BIOS guidance  
└───────────────┬───────┘
                │
                ▼
┌───────────────────────┐
│   Device Type Check  
│   ├─ Laptop/Tablet → run sc_kb.py (screen + keyboard tests)  
│   └─ Tower/Desktop → skip test  
└───────────────┬───────┘
                │
                ▼
┌───────────────────────┐
│   Generate sysinfo.log  
│   Send log via TCP to Receiver (IP:Port)  
│   Include RAID notes if applicable  
└───────────────┬───────┘
                │
                ▼
┌───────────────────────┐
│   Delete sysinfo.log  
│   Power off system  
└───────────────────────┘
