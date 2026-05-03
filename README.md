# Duckio OS (Windows 11, but better)

Duckio OS is a repeatable **Windows 11 optimization profile** plus USB-prep tooling so you can install on a real PC.

## Important reality check

Duckio OS is built **on top of official Windows 11 media**. It is not a replacement Microsoft kernel.

## What you get

- Bootable USB creation flow using official Windows 11 ISO.
- Post-install tuning script (`duckio-setup.ps1`).
- Optional app bootstrap script (`duckio-apps.ps1`).
- Rollback and logging support.

## Build a Duckio USB installer (Windows admin PowerShell)

1. Put the official Windows 11 ISO on your machine.
2. Plug in a USB drive (8GB+). **All data on it will be erased**.
3. Run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\tools\prepare-duckio-usb.ps1 -IsoPath "C:\ISO\Win11.iso" -UsbDiskNumber 3 -UsbDriveLetter E
```

This will:
- Partition/format the USB as GPT/FAT32.
- Copy Windows setup files.
- Add Duckio scripts under `E:\duckio`.

## Install on a real PC

1. Boot target PC from the Duckio USB.
2. Install Windows 11 normally.
3. After first login, copy `duckio` folder from USB to `C:\duckio`.
4. Open elevated PowerShell and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
C:\duckio\duckio-setup.ps1
```

## Setup modes

```powershell
# Skip app installs
C:\duckio\duckio-setup.ps1 -SkipApps

# More aggressive telemetry reduction
C:\duckio\duckio-setup.ps1 -StrictPrivacy

# Undo to backed-up defaults
C:\duckio\duckio-setup.ps1 -Rollback
```

## Safety + logs

- Log file: `C:\ProgramData\Duckio\duckio-setup.log`
- Registry backup: `C:\ProgramData\Duckio\registry-backup.json`

## Hardware compatibility

See `docs/hardware-checklist.md` for UEFI/TPM/Secure Boot and post-install validation requirements.
