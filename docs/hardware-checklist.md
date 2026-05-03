# Hardware checklist (real PC readiness)

Use this checklist before deploying Duckio OS profile to physical hardware.

## Firmware

- UEFI mode enabled (legacy/CSM disabled).
- Secure Boot enabled.
- TPM 2.0 enabled and active.

## Minimum hardware

- CPU: 4+ cores, 64-bit, modern virtualization support.
- RAM: 8 GB minimum (16 GB recommended).
- Storage: 128 GB SSD minimum.
- GPU: DirectX 12 compatible.

## Deployment checks

- BIOS updated to latest stable release.
- Storage controller set to AHCI unless RAID required.
- Network driver available (Wi‑Fi/Ethernet).
- BitLocker recovery workflow tested.

## Post-install validation

- Windows Update fully patched.
- Device Manager has no unknown devices.
- `scripts/duckio-setup.ps1` ran without errors.
- Restore point exists and can be listed in System Restore.
