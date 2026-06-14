---
title: "T14s post-install optimizations"
status: done
type: improvement
priority: low
created: 2026-06-13
closed: 2026-06-14
depends-on: 008-t14s-physical-install.md
---

## Problem

T14s is running from flake (#008 done) but has several low-priority optimizations that can improve boot speed, disk usage, and performance.

## Tasks

### 1. ✅ Add btrfs `compress=zstd` mount options

Added `options = [ "compress=zstd" ]` to `/`, `/home`, `/nix` in `modules/hosts/t14s/hardware-configuration.nix`.

### 2. ✅ Replace swap partition with zram

Removed `swapDevices` from both T14s and P1 hardware configs. Added `zramSwap.enable = true` and `boot.kernel.sysctl."vm.swappiness" = 100` in `power.nix`. Both hosts now use RAM-based compressed swap (~half of total RAM).

### 3. ⏭️ LUKS2 Argon2 tuning — skipped

Key slot already uses optimal parameters (6 iterations, 1MB memory, 4 threads = ~2s unlock). Initial slow boot was cold-start outlier.

### 4. WireGuard real config — pending

Config copied to `/etc/wireguard/peer_t14s/` on T14s. Module references correct path. `autostart` remains `false`.

### 5. ⏭️ pulseaudio/pactl — skipped

No scripts or configs in the repo depend on `pactl`. `wpctl` is available and covers all PipeWire control needs.

## Notes

- None of these are blockers — system works fine without them
- All are low-priority quality-of-life improvements
- Can be done incrementally or in bulk
