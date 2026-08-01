        SOFTLANDING UEFI BOOTKIT — TECHNICAL ADVISORY      
        Multi-Agent Cross-Platform Firmware Implant        
                                                           
  AUTHOR:     ares-sys                                     
  DATE:       28 July 2026                                 
  TLP:        WHITE — Public Disclosure                    
                                                           

"Your PC may still be infected. Reinstalling the OS will not
help. The enemy is not in your files — it is in your firmware."

EXECUTIVE SUMMARY
A previously undocumented UEFI DXE bootkit — designated
"SoftLanding" — has been identified, extracted via SPI flash
dump,The implant targets
Gigabyte motherboards and 240+ additional motherboard
models vulnerable to CVE-2025-7029.

The implant executes at the DXE phase of UEFI firmware
(Ring -2), before any operating system loads. It deploys
three-tiered agents (firmware, kernel, userland) across
Windows, Linux, and macOS with dual C2 architecture.

Distribution occurs via SEO poisoning + AI chatbot
recommendations, disguised as legitimate software
installers (VSCode, hardware monitoring tools).

C2 infrastructure is hosted on bulletproof hosting providers
spanning multiple jurisdictions, using a 90+ node global
SOCKS/HTTP proxy layer for relay and anonymization.

TECHNICAL ANALYSIS

1. INFECTION CHAIN

   STAGE 1: SEO Poisoning / AI Chatbot Recommendation
   → Fake download page → VSCodeUserSetup-x64-1.113.0.exe
   (139MB, legitimate = 90MB, +49MB payload)
   SHA256: D8D807F731D4ACA5F6DE0F09EFCCFDCFFFF40821
           87458557F10FB2BEEB35A5C4

   STAGE 2: CVE-2025-7029 Exploitation
   OverClockSmiHandler SMM corruption → RBX = '$DB$'
   → Arbitrary SMRAM write → SPI flash protection bypass

   STAGE 3: DXE Driver Installation
   Driver written to SPI flash (Ring -2)
   VenHw(99E275E7-75A0-4B37-A2E6-C5385E6C00CB) registered
   EFI artifacts deployed: mach_kernel, SystemVersion.plist

   STAGE 4: Multi-Agent Deployment
   Agent-1 (kernel) → memory exfiltration
   Agent-2 (userland) → mining + C2 + lateral movement
   AI-powered Ollama-based polymorphic code mutation

2. IMPLANT ARCHITECTURE

   AGENT-0 (ROOT — SPI Flash, DXE Phase, Ring -2)
   → Deploys Agent-1 and Agent-2 every boot
   → Monitors EFI partition, regenerates artifacts
   → UEFI network stack for pre-boot C2 beacon
   → Deadman switch: triggers destructive action on tamper

   AGENT-1 (KERNEL — C2-EXFIL, Near Real-Time)
   → DMA physical memory access
   → Syscall interception (read/write/send/recv)
   → Credential capture (passwords, keys, tokens)
   → Process memory exfiltration (browsers, wallets, SSH agents)

   AGENT-2 (USERLAND — C2-OPS, Persistent Connection)
   → Interactive remote shell (Windows/Linux/macOS)
   → GPU mining (XMRig/CryptoNight) + unauthorized LLM inference
   → AI-powered code mutation (Hades scanner evasion)
   → Lateral movement (SSH, SMB, RDP, WinRM)
   → Screen, keystroke, and microphone capture

3. AI-POWERED EVASION

   ┌─────────────┐      ┌──────────────┐
   │ AV Scanner   │ ───→ │  LLM (Ollama) │
   │ detects      │      │  rewrites     │
   │ signature    │      │  malware code │
   └─────────────┘      └──────┬───────┘
                               │
                       ┌───────▼────────┐
                       │  NEW VARIANT   │
                       │  New SHA256    │
                       │  Undetected    │
                       └────────────────┘

   Documented as "Hades" technique by Zscaler.
   The implant abuses the victim's GPU to run Ollama for
   real-time polymorphic code mutation — every AV scan
   produces a new, undetectable variant.

INDICATORS OF COMPROMISE

FIRMWARE (ALL PLATFORMS):
  efibootmgr:   VenHw(99E275E7-75A0-4B37-A2E6-C5385E6C00CB)
  EFI:          /boot/efi/mach_kernel (34 bytes)
                "This file is required for booting"
  EFI:          /boot/efi/System/Library/CoreServices/
                SystemVersion.plist
                (<string>Linux</string>)

WINDOWS:
  Task:         SoftLandingCreativeManagementTask
  CLSID:        {F576B2F9-7850-4226-ADB0-E5993FED4F02}
  Registry:     HKLM\...\TaskCache\Tree\SoftLanding

DROPPER:
  SHA256:       D8D807F731D4ACA5F6DE0F09EFCCFDCFFFF40821
                87458557F10FB2BEEB35A5C4
  Name:         VSCodeUserSetup-x64-1.113.0.exe
  Size:         139MB (legitimate ≈ 90MB)

C2 INFRASTRUCTURE:

  PROXY LAYER (90+ SOCKS/HTTP nodes, 30+ countries):
    190.153.121.2:4145  177.101.135.89:5678
    103.113.71.230:1080 68.71.254.6:4145
    162.214.102.121:52730  +85 more
    Source: Pastebin GS5wzAvL (active relay list)

  C2 LAYER:
    t.m-kosche[.]com:443
    83.142.209.194, 83.142.209.11, 83.142.209.203
    185.95.159.32
    Subnet: 83.142.209.0/24
    AS205759, AS202412

  P2P FALLBACK:
    filev2.getsession[.]org/file/ (Session Network)

  DEADMAN SWITCH:
    Token: "IfYouRevokeThisTokenItWillWipeTheComputerOfTheOwner"
    Triggers destructive action on credential revocation
    or persistent tamper detection.

DETECTION

QUICK CHECK (Linux — as root):
  sudo efibootmgr | grep -i "VenHw"
  sudo find /boot/efi -name "mach_kernel"
  sudo find /boot/efi -name "SystemVersion.plist"

  ANY result = YOU ARE INFECTED.

QUICK CHECK (Windows — PowerShell Admin):
  schtasks /query /fo LIST /v | findstr /i "softland"
   bcdedit /enum firmware | findstr /i "VenHw"
  Get-UEFIBootEntry | Where-Object { $_.Description -like "VenHw" }
  schtasks /query /fo LIST /v | findstr /i "softland"


YARA RULES:
  rule SoftLanding_DXE_Driver {
    strings:
      $venhw = "VenHw(99E275E7" nocase wide
      $mk = "mach_kernel"
      $sv = "SystemVersion.plist"
      $db = "$DB$"
      $boot = "This file is required for booting"
    condition: 2 of them
  }

  rule SoftLanding_EFI_Artifacts {
    strings:
      $a = "This file is required for booting"
      $b = "<string>Linux</string>"
    condition: filesize < 200KB and ($a or $b)
  }

REMEDIATION

WARNING: Reinstalling the OS WILL NOT remove this implant.
Q-Flash Plus WILL NOT remove it. The implant is in the SPI
flash chip. PHYSICAL REPROGRAMMING IS REQUIRED.

REQUIRED:
  — CH341A USB SPI programmer (~$5 USD)
  — SOIC8 test clip
  — Clean Gigabyte firmware (32MB, verified)
  — flashrom v1.3+

PROCEDURE:
  1. Power off (PSU switch + cable removed)
  2. Locate SPI flash chip (SOP8, near southbridge)
  3. Connect CH341A + SOIC8 clip (3.3V — NEVER 5V!)
  4. Backup: flashrom -p ch341a_spi -r infected.bin
  5. Write:  flashrom -p ch341a_spi -w clean.bin
  6. Verify: flashrom -p ch341a_spi -v clean.bin
  7. Wipe disks, reinstall OS AIR-GAPPED
  8. Cold reboot ×3, verify no VenHw/EFI artifacts
  9. Reconnect network, monitor 72 hours

AFFECTED SYSTEMS

CONFIRMED VULNERABLE:
  Multiple Gigabyte motherboard models (all firmware versions)
  Models with OverClockSmiHandler SMI handler exposed

POTENTIALLY VULNERABLE:
  240+ Gigabyte motherboards (Binarly BRLY-2025-009)
  All models with OverClockSmiHandler SMI handler

AFFECTED OS:
  Windows 10/11, Linux (any distro), macOS
  (DXE driver executes regardless of OS)

KNOWN PUBLIC VICTIMS:
  Reddit r/antivirus: 3 users (March 2026)
  ElevenForum: 1 user (April 2026)
  BleepingComputer: 1 user (April 2026)
  Estimated true count: 1000+ (most undiagnosed)


"Verify your firmware. Don't trust what your OS
 tells you. The enemy is beneath everything you can see."


                          — ares-sys, July 2026

