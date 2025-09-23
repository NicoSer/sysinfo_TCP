# Security Overview — Sysinfo Project

## Purpose
**Sysinfo** is a portable diagnostic and logging utility designed to:
- Collect system information quickly (hardware, serial, memory, CPU).
- Verify screen/keyboard functionality (auto-detects laptop vs desktop).
- Send logs over TCP to a configured receiver.
- Save employee time during hardware checks.

It runs from a **bootable USB** (Ubuntu Server 24.04.3 LTS, lightweight build, Secure Boot certified).

---

## Security Characteristics

- **Minimal OS**  
  - Ubuntu Server 24.04.3 LTS (no GUI, no browsers, no extra packages).  
  - No persistent services beyond the Sysinfo runtime.  

- **Autostart & Controlled Runtime**  
  - Boots directly into Sysinfo under root autologin.  
  - Users interact only through the script prompts (Wi-Fi SSID/password, receiver IP/port).  

- **Network Behavior**  
  - Connects only when Wi-Fi or Ethernet is configured by the user.  
  - Transmits logs via TCP to the configured IP:Port.  
  - No background traffic or external connections.  

- **Data Handling**  
  - Logs are collected, transmitted, and then **deleted automatically**.  
  - No logs or data remain on the machine after shutdown.  

---

## Known Limitations

- Someone with **physical access** to the USB can modify the image.  
- Logs are transmitted in plain TCP (unencrypted).  
- Network setup requires SSID/password input for Wi-Fi.  
  - This is only prompted once, since the configuration is saved for future runs.  
- RAID controllers will not be fully detected; Sysinfo includes a fallback to handle this gracefully by showing how to switch to AHCI per vendor.  
- These scripts are designed to run inside the preconfigured `sysinfo.img`.  
  - The image ships with all required dependencies pre-installed (`inxi`, `smartctl`, `evdev`, etc.).  
  - The default environment uses the **roots** user. Running outside of `sysinfo.img` may require adjusting file paths or usernames.  

---


## Future Options (Available on Request)

The following features are not part of the current build but can be added if requested via a [GitHub Feature Request](../../issues):

- **Secure Port Assignment** → automatic port assignment with firewall rules.  
- **Encrypted Log Files** → logs written and transmitted in encrypted format.  
- **Encrypted sysinfo.conf** → optional encryption of stored Wi-Fi credentials and settings.  

---

## License & Attribution

- **License:** Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International.  
  - ✅ Free to use and distribute as-is.  
  - ❌ No modifications.  
  - ❌ No commercial use.  

- **Attribution:** Created by **Nicolas (2025)**.  
  - License headers included in all scripts.  
  - GitHub repository: [NicoSer/sysinfo_TCP](https://github.com/NicoSer/sysinfo_TCP).  

---

## Contact
For questions, bug reports, or feature requests:  
→ Please use the [Issues tab](../../issues) on GitHub.  
