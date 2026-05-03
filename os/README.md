# Duckio OS Kernel Prototype

This is a **real bare-metal operating system prototype** (not a Windows script) using Rust + Limine.

## What it does now

- Boots on x86_64 UEFI/BIOS hardware through Limine.
- Draws a framebuffer UI splash saying `Duckio OS`.
- Confirms kernel execution on real hardware.

## Build outline

1. Install nightly Rust + target:
   - `rustup target add x86_64-unknown-none`
2. Build kernel:
   - `cargo build --release --manifest-path os/kernel/Cargo.toml`
3. Place binary as `boot/duckio-kernel` in a Limine bootable image.
4. Copy `os/limine/limine.conf` into image `boot/limine/limine.conf`.
5. Write the image to USB and boot on PC.

## Reality note

A complete desktop OS requires scheduler, memory manager, storage drivers, input stack, graphics compositor, and package/update system. This commit creates the real bootable starting point.
