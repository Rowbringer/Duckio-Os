# Duckio OS (Windows 11, but better)

Duckio OS is a repeatable **Windows 11 optimization profile** designed for real physical PCs.

## What this project is

- A scriptable post-install profile for Windows 11.
- A safer alternative to random debloat scripts.
- Version-controlled system tuning with rollback support.

## What this project is not

- Not a replacement Windows kernel.
- Not an unofficial ISO distro.
- Not bypassing core security requirements for production machines.

## Features

- Restore point + registry backup before making changes.
- One-command setup via elevated PowerShell.
- Optional strict privacy mode.
- Optional rollback mode.
- Optional app bootstrap with Winget.

## Quick start (real PC)

Open elevated PowerShell in this repo and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\duckio-setup.ps1
```

### Useful modes

```powershell
# Skip app installs
.\scripts\duckio-setup.ps1 -SkipApps

# More aggressive telemetry reduction
.\scripts\duckio-setup.ps1 -StrictPrivacy

# Undo to backed-up defaults
.\scripts\duckio-setup.ps1 -Rollback
```

## Safety + logs

- Log file: `C:\ProgramData\Duckio\duckio-setup.log`
- Registry backup: `C:\ProgramData\Duckio\registry-backup.json`
- Reboot after applying or rolling back.

## Hardware compatibility

See `docs/hardware-checklist.md` for UEFI/TPM/Secure Boot and post-install validation requirements.
