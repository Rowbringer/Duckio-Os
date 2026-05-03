# Duckio OS (Windows 11, but better)

Duckio OS is a **production-minded Windows 11 customization toolkit** that builds a cleaner, faster, and more private Windows install image for real PCs.

It does this by:
- Applying repeatable post-install tuning via PowerShell.
- Turning off common telemetry and background noise.
- Installing sane defaults for developer and power-user workflows.
- Keeping full hardware compatibility by staying on top of official Windows 11 media.

> This repo does **not** replace the Windows kernel. It automates creation of a better Windows 11 deployment profile you can install on actual hardware.

## Goals

- ✅ Runs on physical PCs (UEFI + TPM 2.0 capable hardware).
- ✅ Deterministic setup from version-controlled scripts.
- ✅ Reversible and auditable system changes.
- ✅ No shady binaries; only built-in Windows tools and open package managers.

## Quick start

1. Download official Windows 11 ISO from Microsoft.
2. Create a USB installer (Rufus or Media Creation Tool).
3. Install Windows 11 normally.
4. After first login, run an elevated PowerShell session:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\duckio-setup.ps1
```

## What gets improved

- Reduced startup and background bloat.
- Telemetry minimized (without breaking updates).
- Explorer and taskbar behavior tuned for desktop productivity.
- Optional software bootstrap through Winget.
- Security defaults kept on (Defender + SmartScreen + BitLocker capable).

## Compatibility

- Windows 11 23H2 or later.
- Secure Boot / UEFI supported.
- Real hardware support (not VM-only).

## Safety model

- A restore point is created before major changes.
- Registry writes are centralized and documented.
- Each action logs to `C:\ProgramData\Duckio\duckio-setup.log`.

## Repository layout

- `scripts/duckio-setup.ps1` — main hardening and debloat script.
- `scripts/duckio-apps.ps1` — optional app bootstrap via Winget.
- `docs/hardware-checklist.md` — real-PC readiness checklist.

## License

MIT
