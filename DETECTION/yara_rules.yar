/*
 * SOFTLANDING UEFI BOOTKIT — YARA Detection Rules
 * Author: ares-sys — July 2026
 * TLP: WHITE
 *
 * Apply to: firmware dumps, EFI partitions, memory images
 */

// ─── DETECT DXE DRIVER IN FIRMWARE ───
rule SoftLanding_DXE_Driver_Firmware {
    meta:
        description = "Detects SoftLanding DXE driver in SPI firmware dumps"
        author = "ares-sys"
        date = "2026-07-28"
        severity = "CRITICAL"
        threat = "UEFI Bootkit"
        reference = "CVE-2025-7029"
        tlp = "WHITE"
    strings:
        $venhw1 = "VenHw(99E275E7-75A0-4B37-A2E6-C5385E6C00CB)" nocase wide
        $venhw2 = "99E275E7-75A0-4B37-A2E6-C5385E6C00CB" nocase ascii
        $mk = "mach_kernel" nocase
        $sv = "SystemVersion.plist" nocase
        $db = "$DB$" ascii
        $smm = "OverClockSmiHandler" nocase wide
    condition:
        (uint32(0) == 0x5f4e495f or uint32(0) == 0x0000005f) and
        3 of ($venhw*, $mk, $sv, $db, $smm)
}

// ─── DETECT EFI ARTIFACTS ON DISK ───
rule SoftLanding_EFI_Artifacts_Disk {
    meta:
        description = "Detects SoftLanding EFI artifacts on disk"
        author = "ares-sys"
        date = "2026-07-28"
        severity = "CRITICAL"
        reference = "IOC: mach_kernel, SystemVersion.plist"
        tlp = "WHITE"
    strings:
        $a = "This file is required for booting"
        $b = "<string>Linux</string>"
        $c = "SystemVersion.plist"
        $d = "CoreServices"
    condition:
        filesize < 200KB and
        (2 of ($a, $b, $c)) and
        $d
}

// ─── DETECT SOFTLANDING IN MEMORY ───
rule SoftLanding_Memory_Implant {
    meta:
        description = "Detects SoftLanding agent in runtime memory"
        author = "ares-sys"
        date = "2026-07-28"
        severity = "HIGH"
        tlp = "WHITE"
    strings:
        $c2_a = "t.m-kosche.com" nocase ascii
        $c2_b = "filev2.getsession.org" nocase ascii
        $guid = "{F576B2F9-7850-4226-ADB0-E5993FED4F02}" nocase ascii
        $task = "SoftLandingCreativeManagementTask" nocase wide
        $token = "IfYouRevokeThisTokenItWillWipeTheComputerOfTheOwner" nocase ascii
    condition:
        2 of them
}

// ─── DETECT DEAD-DROP COMPONENTS ───
rule DeadDrop_Components {
    meta:
        description = "Detects dead-drop malware components"
        author = "ares-sys"
        date = "2026-07-28"
        severity = "HIGH"
        tlp = "WHITE"
    strings:
        $repo1 = "Shai-Hulud" nocase
        $repo2 = "Sha1-Hulud: The Second Coming" nocase ascii
        $repo3 = "Goldox-T3chs: Only Happy Girl" nocase ascii
        $c2 = "/tmp/transformers.pyz" ascii
        $exfil = "enc_key.pub" ascii
        $exfil2 = "verify_key.pub" ascii
        $dead = "IfYouRevokeThisTokenItWillWipeTheComputerOfTheOwner" nocase ascii
    condition:
        3 of them
}

// ─── DETECT VSCode DROPPER ───
rule SoftLanding_VSCode_Dropper {
    meta:
        description = "Detects the trojanized VSCode installer"
        author = "ares-sys"
        date = "2026-07-28"
        severity = "CRITICAL"
        hash = "D8D807F731D4ACA5F6DE0F09EFCCFDCFFFF4082187458557F10FB2BEEB35A5C4"
        tlp = "WHITE"
    strings:
        $hash_match = "D8D807F731D4ACA5F6DE0F09EFCCFDCFFFF40821" ascii
        $db_magic = "$DB$" ascii
        $smi = "OverClockSmiHandler" nocase wide
        $driver = "DXE" ascii
    condition:
        filesize > 100MB and
        filesize < 200MB and
        $db_magic and
        ($smi or $driver)
}
