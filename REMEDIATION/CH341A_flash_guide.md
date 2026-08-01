# SOFTLANDING UEFI BOOTKIT — Remediation Guide
# Author: ares-sys — JULY 2026

CRITICAL WARNING

SOFTWARE REMEDIATION IS IMPOSSIBLE.

  This implant lives in the SPI flash chip — a physical
  component soldered to your motherboard. Reinstalling
  the OS, updating the BIOS via Q-Flash, or running any
  antivirus WILL NOT remove it.

  You MUST reprogram the SPI flash chip with an external
  programmer. There is no other way.

STEP 1 — CHECK IF YOU ARE INFECTED

  LINUX:
    sudo efibootmgr | grep -i "VenHw"
    sudo find /boot/efi -name "mach_kernel"
    sudo find /boot/efi -name "SystemVersion.plist"
    → ANY result = INFECTED

  WINDOWS (PowerShell Admin):
    schtasks /query /fo LIST /v | findstr /i "softland"
    → Shows SoftLandingCreativeManagementTask = INFECTED

  PHYSICAL SIGNS:
    - PC runs hot even at idle (GPU mining)
    - Fans spin up randomly
    - Reinstalling OS doesn't fix boot problems
    - "VenHw" entries appear in BIOS boot menu


STEP 2 — ACQUIRE TOOLS


  REQUIRED (~$8 total):
    - CH341A USB SPI programmer
      Amazon/AliExpress search: "CH341A 24 25 Series EEPROM"
    - SOIC8 test clip
      Search: "SOIC8 SOP8 test clip"

  SOFTWARE (Linux preferred):
    sudo apt install flashrom    # or: sudo dnf install flashrom

  CLEAN FIRMWARE:
    Download the exact BIOS/firmware for YOUR motherboard
    from your manufacturer's official support page.
    Gigabyte: https://www.gigabyte.com/Support
    Extract the .bin or .rom file (typically 16-32MB).

STEP 3 — LOCATE THE SPI CHIP

  1. POWER OFF COMPLETELY
     - Shut down normally
     - Switch off PSU
     - Remove power cable
     - Wait 30 seconds for capacitors to discharge

  2. OPEN THE CASE
     - Ground yourself (touch metal case)

  3. LOCATE THE SPI FLASH CHIP
     - 8-pin SOP8 package (4 pins each side)
     - Usually near the southbridge/chipset
     - Markings: Macronix (MX25Lxxxxx), ISSI (IS25WPxxx),
       Winbond (W25Qxxx), or GigaDevice (GD25xxx)
     - Pin 1 has a small dot or notch
     
     Common positions:
     - Bottom right corner near front panel headers
     - Near the BIOS battery
     - Between PCIe slots and chipset heatsink

STEP 4 — CONNECT THE PROGRAMMER

  CH341A Pinout (check your programmer's label):
    1  CS   (Chip Select)    → SPI pin 1 (CS)
    2  MISO (Master In)      → SPI pin 2 (DO/IO1)
    3  MOSI (Master Out)     → SPI pin 5 (DI/IO0)
    4  SCK  (Clock)          → SPI pin 6 (CLK)
    5  GND  (Ground)         → SPI pin 4 (GND)
    8  VCC  (3.3V)           → SPI pin 8 (VCC)

  ⚠️ CRITICAL:
    - Voltage MUST be 3.3V. Some CH341A have a 5V/3.3V jumper.
      SET IT TO 3.3V. 5V WILL DESTROY THE CHIP.
    - Red wire on SOIC8 clip = Pin 1
    - Verify orientation BEFORE connecting USB
    - Never hot-plug the clip (connect clip → then USB)

STEP 5 — BACKUP INFECTED FIRMWARE

  # Identify the chip
  sudo flashrom -p ch341a_spi

  # Read the firmware (this is your forensic evidence!)
  sudo flashrom -p ch341a_spi -r infected.bin

  # Verify the dump
  ls -la infected.bin
  # Should be 16-32MB depending on your motherboard

  # Make a backup copy
  cp infected.bin infected_backup_$(date +%Y%m%d).bin

STEP 6 — WRITE CLEAN FIRMWARE

  # Verify clean firmware size (must match your chip)
  ls -la CLEAN_FIRMWARE.bin

  # WRITE (this is the irreversible step)
  sudo flashrom -p ch341a_spi -w CLEAN_FIRMWARE.bin

  # VERIFY (mandatory!)
  sudo flashrom -p ch341a_spi -v CLEAN_FIRMWARE.bin
  # Output MUST say "VERIFIED" — if not, re-write!

  # Disconnect programmer
  sudo flashrom -p ch341a_spi --flash-name  # just to check
  # Unplug USB, then unclip

STEP 7 — RECONSTRUCTION (AIR-GAPPED!)

  ⚠️ DO NOT connect to network yet!

  1. Power on, enter UEFI/BIOS setup (DEL)
  2. Load optimized defaults
  3. Save and exit

  4. BOOT FROM USB (Fedora/Debian live USB)
     DO NOT boot from any internal disk yet

  5. Wipe ALL internal disks:
     sudo wipefs -a /dev/nvme0n1
     sudo wipefs -a /dev/sda
     (repeat for all disks)

  6. VERIFY — COLD REBOOT ×3:
     After each reboot:
     a) sudo efibootmgr → should show NO "VenHw"
     b) sudo find /boot/efi -name "mach_kernel" → EMPTY
     c) sudo find /boot/efi -name "SystemVersion.plist" → EMPTY

  7. If clean after 3 reboots:
     - Install OS from verified media (USB)
     - Install security tools: fail2ban, firewall
     - Now you can reconnect to network

  8. MONITOR for 72 hours minimum:
     - Watch temperatures (no unexplained heat)
     - Watch network traffic (no calls to 83.142.209.x)
     - Check efibootmgr daily

STEP 8 — POST-REMEDIATION HARDENING

  FIREWALL:
    # Block C2
    sudo iptables -A OUTPUT -d 83.142.209.0/24 -j DROP
    sudo iptables -A OUTPUT -d 185.95.159.32 -j DROP

  DNS SINKHOLE:
    Add to blacklist:
    t.m-kosche.com
    filev2.getsession.org

  VERIFY DOWNLOADS:
    ALWAYS check SHA256 of downloaded installers
    If file size seems off → DO NOT RUN IT

  UEFI MONITORING:
    # Weekly check
    crontab: @weekly efibootmgr | grep -i venhw && alert

SAFETY CHECKLIST (before each step)

  [ ] Power completely OFF
  [ ] Capacitors discharged (30 sec wait)
  [ ] CH341A set to 3.3V (NOT 5V!)
  [ ] Pin 1 orientation verified
  [ ] Clip securely attached
  [ ] USB cable connected LAST
  [ ] Read BEFORE write (always backup first!)
  [ ] Verify after write (mandatory!)
  [ ] USB disconnected BEFORE removing clip

If you need help or found this useful:
  ares-sys — July 2026

