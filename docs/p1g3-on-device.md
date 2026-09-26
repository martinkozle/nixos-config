# P1 Gen 3 — checks to do on the machine itself

Changes for the P1 that should not be committed blind. Each one needs probing
on the running laptop (battery draw, which GPU is awake, what builds locally).
Written 2026-09-23 from a review done on the t14s; nothing here has been tested
on the P1 yet.

Useful probes throughout:

```bash
cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status   # dGPU: "suspended" is what you want on battery
nvidia-smi                                                     # wakes the dGPU; only run when you need it
upower -i $(upower -e | grep BAT)                              # energy-rate = current draw in W
sudo powertop                                                   # per-device/per-process wakeups
lspci -k | grep -A3 -E 'VGA|3D'                                 # which driver is bound
```

## 1. NVIDIA: PRIME mode and battery life

Current `modules/features/nvidia.nix`: proprietary driver (`open = false`),
`powerManagement.finegrained = true`, PRIME `offload` (turned on by nixos-hardware's
p1-gen3 profile) **plus** `reverseSync.enable = true`.

Why reverseSync is suspect: PRIME sync/reverse-sync/offload are Xorg concepts —
the NixOS options mostly write Xorg config. Under Hyprland (Wayland) the compositor
picks GPUs itself via Aquamarine, so reverseSync most likely does nothing except
add Xorg config that is never read. Offload + finegrained is what actually lets the
dGPU power down.

Suggestions to test, one at a time, measuring `energy-rate` idle on battery with no
external monitor before and after:

1. Drop `reverseSync.enable`. Expect: no change. If external monitors on HDMI
   (wired to the dGPU on this model) still work, keep it dropped.
2. Tell Hyprland to render on the iGPU and use the dGPU only for outputs wired
   to it, so the dGPU can sleep when no external monitor is connected:
   `env = AQ_DRM_DEVICES,/dev/dri/by-path/pci-0000:00:02.0-card:/dev/dri/by-path/pci-0000:01:00.0-card`
   (first entry = primary renderer; `by-path` avoids card0/card1 renumbering —
   check the real names with `ls -l /dev/dri/by-path`). Colons inside the paths
   must be escaped as `\:` in hyprland.conf — test the exact syntax.
   Then check `runtime_status` reads `suspended` with only the laptop panel on.
3. Try `open = true`. The P1 Gen 3 ships a Quadro T1000/T2000 (Turing), where NVIDIA
   recommends the open kernel modules. Confirm with `lspci`. Watch for suspend/resume
   regressions.
4. `GSK_RENDERER=gl` is still set on the P1 (moved here from the shared Hyprland
   config, dropped on the t14s). It was added in Jan 2025 when GTK 4's new renderer
   misbehaved; remove it and see if GTK 4 apps render fine.

## 2. OBS with `cudaSupport = true`

Set in `modules/features/nvidia.nix`. With it, OBS is not in cache.nixos.org and
compiles locally on every OBS/dependency bump (confirmed 2026-09-23: a dry-run of
the p1g3 system lists `obs-studio-32.1.2.drv` under "will be built").

NVENC: the Turing Quadros have a hardware NVENC encoder, so NVENC is supported.
The open question is whether nixpkgs' plain `obs-studio` already exposes the
NVENC encoders (OBS loads `libnvidia-encode` at runtime from the driver), which
would make the CUDA rebuild unnecessary.

Test: build a generation without the override (`nix build` only, don't switch),
run that OBS, check Settings → Output → Encoder for "NVIDIA NVENC H.264/HEVC/AV1".
If present and recording works, drop the override. Also check
`nix build --dry-run` of the system to see what currently compiles locally.

## 3. The second LUKS device (`luks-p1g3.nix`)

`luks-c63de383-…` is unlocked at boot but nothing uses it (`swapDevices = []`).
It is most likely the installer's encrypted swap. On the P1:

```bash
lsblk -f                                     # what is inside /dev/mapper/luks-c63de383-…
sudo blkid /dev/mapper/luks-c63de383-*       # TYPE="swap"?
```

If it is swap, add it as a lower-priority swap device behind zram (same pattern
as `modules/features/disks-t14s.nix`, but it is already LUKS-unlocked so point
`swapDevices` at `/dev/mapper/luks-c63de383-…` with no `randomEncryption`).
That also makes hibernation possible later (needs `boot.resumeDevice`).

## 4. `psmouse.synaptics_intertouch=0`

Moved from `base.nix` into `modules/features/touchpad-p1g3.nix`. It came
from commit 0bebb83 "Improve p1g3 trackpad and scroll behavior" (Jul 2025). It only
affects Synaptics PS/2 touchpads; the t14s touchpad is an Elan on I2C (`elan_i2c`)
and was never affected. Optional experiment: remove it and see whether whatever
annoyed you comes back (it forces PS/2 mode instead of the SMBus/RMI4 mode).
