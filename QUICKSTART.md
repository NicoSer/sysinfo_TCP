# QUICKSTART

This guide explains how to quickly run the Sysinfo Project components.

---

## LogViewer

### Requirements
- OpenJDK 17 or newer

### Install & Run

**Windows (Winget):**
```powershell
winget install openjdk
java -jar LogViewer.jar
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt install openjdk-17-jre
java -jar LogViewer.jar
```

**macOS (Homebrew):**
```bash
brew install openjdk@17
java -jar LogViewer.jar
```

✅ LogViewer will now listen for logs sent from `sysinfo.sh`.

---

## sc_kb.py

### Requirements
- python3
- python3-evdev

### Run
```bash
python3 sc_kb.py
```

---

## sysinfo.sh

### Requirements
- dmidecode
- lspci (pciutils)
- inxi
- smartmontools (for smartctl)
- net-tools (for ping)
- NetworkManager (for nmcli)

### Run
```bash
sudo bash sysinfo.sh
```

---

## Notes
- `sysinfo.img` (bootable image) will be provided later.  
- Scripts are designed for the preconfigured `sysinfo.img` (username **roots**, dependencies pre-installed). Running outside may require adjustments.  
- Scripts **do not** carry version numbers in filenames.  
- Version tracking is handled via repo tags/releases.  
- Licensed under **CC BY-NC-ND 4.0**.  
