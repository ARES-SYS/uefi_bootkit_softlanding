# SOFTLANDING UEFI BOOTKIT — ARES-2026-0001

[![Classification](https://img.shields.io/badge/Classification-PUBLIC-brightgreen)](.)
[![TLP](https://img.shields.io/badge/TLP-WHITE-brightgreen)](.)
[![Affected](https://img.shields.io/badge/Affected-240%2B%20Gigabyte%20Models-red)](.)

> **The first public documentation of the SoftLanding UEFI DXE bootkit** — a multi-agent, cross-platform firmware implant that persists in SPI flash (Ring -2), deploys kernel and userland agents, and survives OS reinstallation and BIOS updates.

---

## ⚡ QUICK CHECK — ARE YOU INFECTED?

```bash
# Linux (or Live USB for Win/Mac)
sudo efibootmgr | grep -i "VenHw"
sudo find /boot/efi -name "mach_kernel"
sudo find /boot/efi -name "SystemVersion.plist"

# Check for C2 traffic
ss -tunap | grep -E "4145|5678|1080"
```

**ANY output = investigate immediately.** Reinstalling your OS will not help.  
**The implant survives disk formatting, OS reinstallation, and BIOS updates.**

---

## 🔴 WHAT THIS IS

This is a **UEFI DXE firmware bootkit** installed in the **SPI flash chip** on your motherboard — a physical hardware component. It executes at **Ring -2** BEFORE any operating system loads, making it invisible to:

- All antivirus and EDR software
- OS-level security tools (firewalls, ACLs, iptables)
- Secure Boot and BitLocker
- Disk formatting and OS reinstallation

**It survives:** Disk formatting | OS reinstall | BIOS Q-Flash | AV scans | Apple diagnostics

**It does NOT survive:** Physical SPI flash reprogramming (CH341A)

+## ✅ WHAT TO DO
+
+**If you are NOT infected:**
+1. Update your BIOS to the latest firmware — patches CVE-2025-7029
+2. Enable Secure Boot
+3. Block C2 IPs from `BLOCKLISTS/ip_blocklist.txt`
+
+**If you ARE infected:**
+→ Go to `REMEDIATION/CH341A_flash_guide.md`
+  BIOS updates and OS reinstall will NOT help.
---

## 📦 REPOSITORY CONTENTS

```
├── ADVISORY_SoftLanding_TECHNICAL.md  ← Full technical advisory
├── README.md                          ← YOU ARE HERE
├── DETECTION/
│   ├── yara_rules.yar                 ← Firmware/disk/memory rules
│   ├── snort_suricata.rules           ← Network IDS/IPS rules
│   └── sigma_rules.yml                ← SIEM detection rules
├── REMEDIATION/
│   └── CH341A_flash_guide.md          ← Step-by-step SPI flash recovery
└── LICENSE
```

---

## 🔑 KEY FINDINGS

| Field | Detail |
|-------|--------|
| **First seen** | July 2026 |
| **Infection vector** | SEO-poisoned installers + social engineering |
| **Firmware exploit** | CVE-2025-7029 — Gigabyte OverClockSmiHandler SMM corruption |
| **DXE driver GUID** | `99E275E7-75A0-4B37-A2E6-C5385E6C00CB` |
| **Affected hardware** | 240+ Gigabyte motherboard models (Binarly BRLY-2025-009) |
| **Models affected** | All boards with OverClockSmiHandler SMI handler |
| **Persistence level** | Ring -2 (SPI flash, DXE phase) |
| **Cross-platform** | Windows, Linux, macOS (DXE driver is OS-agnostic) |
| **Multi-agent** | Firmware implant → kernel agent → userland agent |
| **Dual C2** | Memory exfiltration channel + operational control |
| **AI/ML evasion** | GPU-accelerated code obfuscation |

---

## 🔬 ADDITIONAL RESEARCH

Additional findings discovered during this research are under responsible disclosure. Full advisories will be published after coordinated disclosure windows complete.

---

## 🤝 I WANT TO HELP

**If you found this useful:**
- Star this repo
- Share it with your network

**If you found this bootkit on your system:**
1. DO NOT reinstall your OS — it won't help
2. Read `REMEDIATION/CH341A_flash_guide.md`
3. Send your firmware dump to help research
4. Report to abuse.ch / AlienVault OTX with tag `ARES-2026-0001`
---

> *"Trust nothing. Verify everything. The enemy is not in your OS. It is in your firmware."*
> — ares-sys, July 2026
