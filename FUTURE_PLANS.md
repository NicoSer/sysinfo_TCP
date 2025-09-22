# Planned Features

This document outlines the planned improvements and future directions for the Sysinfo project.

---

## LogViewer.jar (Receiver Application)
- [ ] Notification sound when a new "Live Update" arrives.  
- [ ] Display new "Live Update" entries in green, fading to white over time.  
- [ ] Optionally purge console logs after X minutes.  
- [ ] Update display text:  
  - `"<ip>," and "Listening to : <port>"` → `Receiver's <IP> - Receiver's Port <PORT>`.  
- [ ] Window header set to:  
  - `TCP Listener <version> <port:ip>` with a custom logo/icon.  
- [ ] Settings option: **Always Stay on Top**.  

---

## sysinfo.img (Bootable USB Image)
- [ ] Optimize system image for faster boot.  
- [ ] Add a splash/loading screen instead of verbose boot messages.  
- [ ] Display `System Information by <author>` with a custom animation (optional).  

---

## sysinfo.sh (Security-Focused Build)
- [ ] Lock terminal so only the script runs (no CTRL+C, TTY switching, or shell escape).  
- [ ] Add UFW firewall and secure TCP connection limited to assigned IP/Port.  
- [ ] Password-protected log transfer:  
  - Receiver password required (numeric).  
  - Password used as decryption key for `sysinfo.log`.  
  - Encrypt `sysinfo.conf` (Wi-Fi + Receiver settings) with a generated encryption key.  
- [ ] LogViewer.jar to require password for decryption before logs can be displayed.  
- [ ] Alternative security mode:  
  - Sysinfo.sh generates a short-lived (3–5 char) key valid for 10h.  
  - Logs encrypted with this key; after expiration logs cannot be decrypted.  
  - LogViewer.jar checks if logs are encrypted:  
    - If encrypted and no key → display warning: *"Log Encrypted, Provide key from Sysinfo.sh"*.  
    - If not encrypted → process as normal.  
- [ ] Time validation for key expiry:  
  - Use trusted online source (e.g. `https://worldtimeapi.org/timezone/America/Montreal`) to prevent bypassing with dead CMOS clocks.  

---

## Notes
- These features are **planned**, not implemented in the current build.  
- Current release = baseline version described in [SECURITY.md](SECURITY.md).  
- Planned features can be formally requested through a [GitHub Feature Request](../../issues).  
