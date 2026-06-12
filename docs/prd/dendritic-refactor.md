# PRD: Dendritic Refactor — Multi-Host NixOS Configuration

## Problem Statement

I have a new laptop (Lenovo ThinkPad T14s Gen 1, Intel i7 10th gen, 1080p display, no dedicated GPU) that I want to make my primary machine. My current laptop (Lenovo ThinkPad P1 Gen 3, Intel + NVIDIA Optimus, multi-monitor) will remain in use. Both need NixOS managed from this single flake repository.

The current configuration is a flat, single-host monolith (~1130 lines across `configuration.nix` and `home.nix`) with host-specific settings (NVIDIA GPU, LUKS UUIDs, WireGuard configs, monitor outputs, NFS mounts) baked into shared files. Adding a second host is not feasible without significant refactoring.

## Solution

Refactor the configuration from a flat monolithic structure to the Dendritic pattern (flake-parts + import-tree), then add the second host. The Dendritic pattern treats each feature as a self-contained module file that can contribute to both NixOS and Home Manager simultaneously. Hosts become thin assembly files that import the features they need.

**Key benefits:**
- NVIDIA config lives in one module imported only by `p1g3` — no conditionals in shared code
- ~90% shared config (Hyprland, packages, shell, services) lives in modules both hosts import
- Adding future hosts is trivial — just a new host file listing modules
- Host diffs reveal exactly what differs between machines

## User Stories

1. As a developer, I want to build my NixOS configuration for the P1 Gen 3 (`p1g3`) and have it produce the same system as before the refactor
2. As a developer, I want to build my NixOS configuration for the T14s Gen 1 (`t14s`) and have it produce a working system without NVIDIA dependencies
3. As a developer, I want to add a new host by creating a single host file and a hardware config, without modifying shared modules
4. As a developer, I want to diff two host files to see exactly which features differ between machines
5. As a developer, I want to modify a shared feature (e.g., Hyprland keybinds) in one file and have it propagate to both hosts
6. As a developer, I want the NVIDIA module to be completely absent from the T14s build, avoiding unfree package downloads and build time
7. As a developer, I want WireGuard to work on both laptops with different interface configurations
8. As a developer, I want OBS Studio to use NVIDIA CUDA on the P1 and Intel VA-API on the T14s
9. As a developer, I want Docker with nvidia-container-toolkit on the P1 and plain Docker on the T14s
10. As a developer, I want both laptops to share the same Hyprland WM configuration (keybinds, animations, input settings)
11. As a developer, I want both laptops to share the same package set, shell config, editor configs, and theme
12. As a developer, I want both laptops to support the same external monitors (Dell AW3423DWF ultrawide + MSI MAG241CR)
13. As a developer, I want each refactoring phase to produce a buildable configuration that I can deploy and verify before proceeding
14. As a developer, I want new agents (AI or human) to be able to read documentation and understand the configuration structure without needing the original design conversation

## Implementation Decisions

### Architecture: Dendritic Pattern (flake-parts + import-tree)

- Use `flake-parts` library for module orchestration
- Use `lib.import-tree` to auto-discover `.nix` files under `modules/`
- Each module file registers itself into a catalog namespace (e.g., `flake.nixosModules.<name>`, `flake.homeModules.<name>`)
- Host files are thin assemblies that import modules from the catalog
- `flake.nix` becomes ~15 lines that delegate to flake-parts

### Target Directory Structure

```
flake.nix                              # ~15 lines, delegates to flake-parts + import-tree
modules/
  features/
    base.nix                           # Shared: locale, time, user, bootloader, nix settings, nixpkgs config
    graphics.nix                       # Shared: hardware.graphics.enable, NIXOS_OZONE_WL
    nvidia.nix                         # P1 only: NVIDIA driver, modesetting, power management, Prime, nvidiaSettings
    intel-gpu.nix                      # T14s only: i915 kernel module, Intel GPU TLP settings
    hyprland-system.nix                # Shared: programs.hyprland enable, package from input, UWSM, portals
    waybar.nix                         # Shared: waybar config + CSS (HM module)
    hyprlock-idle.nix                  # Shared: hyprlock + hypridle config (HM module)
    networking.nix                     # Shared: NetworkManager, firewall base rules
    wireguard.nix                      # Shared: wg-quick enable. Parametric — each host passes its interface config
    nfs.nix                            # Shared: NFS mount for /mnt/nas (both hosts)
    audio.nix                          # Shared: PipeWire, rtkit, ALSA
    bluetooth.nix                      # Shared: Bluetooth, blueman
    docker.nix                         # Shared: Docker enable. P1 adds nvidia-container-toolkit via nvidia module
    services.nix                       # Shared: OpenSSH, gnome-keyring, seahorse, GPG agent, ydotool, localsend
    security.nix                       # Shared: polkit rules, PAM for hyprlock
    power.nix                          # Shared: thermald. TLP split: nvidia module has P1 TLP, intel-gpu has T14s TLP
    packages-system.nix                # Shared: environment.systemPackages
    packages-home.nix                  # Shared: home.packages (includes opencode patch, codex-cli, etc.)
    shell.nix                          # Shared: zsh, starship, aliases, vi-mode
    editors.nix                        # Shared: LazyVim, VSCode, Zed
    programs.nix                       # Shared: git, firefox, kitty, nh, OBS (CUDA vs VA-API conditional)
    themes.nix                         # Shared: GTK theme, cursor, fonts, dconf dark mode
    monitors-p1g3.nix                  # P1 only: built-in BOE + Dell ultrawide + MSI 1080p
    monitors-t14s.nix                  # T14s only: built-in 1080p + Dell ultrawide + MSI 1080p
  hosts/
    p1g3/
      default.nix                      # Assembly: imports base + nvidia + hyprland + wireguard(p1g3) + monitors-p1g3 + all shared
      hardware-configuration.nix       # Generated by nixos-generate-config (moved from root)
    t14s/
      default.nix                      # Assembly: imports base + intel-gpu + hyprland + wireguard(t14s) + monitors-t14s + all shared
      hardware-configuration.nix       # Generated after T14s install
```

### Module Granularity: ~20 Fine-Grained Modules

Each module owns one coherent feature. Modules contributing to both NixOS and Home Manager register both `nixosModules` and `homeModules` from the same file (e.g., Hyprland).

### Parametric Features (Hybrid Approach)

- **WireGuard:** Parametric module. Both hosts import the same module, passing their interface configuration as arguments.
- **Monitors:** Separate files per host (`monitors-p1g3.nix`, `monitors-t14s.nix`). Monitor configs are too structural to parametrize cleanly.
- **OBS Studio:** Shared module with conditional — CUDA support on P1 (via `lib.mkIf` checking for NVIDIA), VA-API/Mesa on T14s.
- **Docker:** Shared module enables Docker. `nvidia-container-toolkit` lives in the nvidia module (P1-only).
- **TLP:** Split between `nvidia.nix` (P1 settings) and `intel-gpu.nix` (T14s settings).

### Home Manager Integration

- `useGlobalPkgs = true` retained (single-user systems, efficiency)
- `useUserPackages = true` retained
- Home Manager modules live alongside NixOS modules in `modules/features/`
- Modules register both `flake.nixosModules.<name>` and `flake.homeModules.<name>` when a feature has both system and user-side config
- `extraSpecialArgs` passes `inputs` to Home Manager

### nixos-hardware Integration

- P1: continues using `nixos-hardware.nixosModules.lenovo-thinkpad-p1-gen3`
- T14s: no dedicated nixos-hardware module for Intel T14s Gen 1; relies on generated `hardware-configuration.nix`

### Packages from nixpkgs-unstable

- Retain `nixpkgs-unstable` input for packages like `joplin-desktop`, `vscode`, `ty`, `uv`, `vesktop`
- Each module that needs unstable packages imports `nixpkgs-unstable` from inputs

### Existing Inputs Preserved

All current flake inputs are preserved: `nixpkgs` (26.05), `nixpkgs-unstable`, `hyprland`, `home-manager` (26.05), `nixos-hardware`, `git-hooks`, `lazyvim`, `codex-cli-nix`, `opencode`.

Add: `flake-parts` input.

### Custom Opencode Patch

The `postPatch` override for opencode (bun version check bypass) remains in the packages module.

### Scripts Directory

The `scripts/` directory pattern (auto-converting shell scripts to packages) remains in the home packages module.

### Migration: 5 Incremental Phases

Each phase produces a buildable configuration verified by `nixos-rebuild build --flake .#p1g3`.

**Phase 1: ✅ flake-parts skeleton** (a8c1038)
- Add `flake-parts` input
- Rewrite `flake.nix` to use flake-parts + import-tree
- Move `configuration.nix` → `modules/features/base.nix`
- Move `hardware-configuration.nix` → `modules/hosts/p1g3/hardware-configuration.nix`
- Create `modules/hosts/p1g3/default.nix` (thin assembly)
- Move `home.nix` → single `modules/home/default.nix` (not yet split)
- Verify: `nixos-rebuild build --flake .#p1g3` produces identical system

**Phase 2: Split NixOS modules**
- Extract from `base.nix`: `nvidia.nix`, `networking.nix`, `wireguard.nix`, `audio.nix`, `bluetooth.nix`, `docker.nix`, `services.nix`, `security.nix`, `power.nix`, `packages-system.nix`, `nfs.nix`, `graphics.nix`, `hyprland-system.nix`
- Update `hosts/p1g3/default.nix` imports
- Verify: build succeeds

**Phase 3: Split Home Manager modules**
- Extract from `modules/home/default.nix`: `packages-home.nix`, `shell.nix`, `editors.nix`, `programs.nix`, `themes.nix`, `waybar.nix`, `hyprlock-idle.nix`
- Register modules as `homeModules` (and `nixosModules` where applicable)
- Verify: build succeeds, desktop environment works

**Phase 4: Clean up and remove old files**
- Remove root-level `configuration.nix`, `home.nix`, `hardware-configuration.nix`
- Ensure `checks` and `devShells` in flake.nix work with new structure
- Verify: `nix flake check` passes, build succeeds

**Phase 5: Add T14s host**
- Install NixOS on T14s, generate `hardware-configuration.nix`
- Create `modules/hosts/t14s/default.nix` with shared modules + `intel-gpu.nix` + `monitors-t14s.nix` + parametric wireguard
- Create `monitors-t14s.nix` and `intel-gpu.nix`
- Add `t14s` to `nixosConfigurations`
- Verify: `nixos-rebuild build --flake .#t14s` succeeds

### Host Naming Convention

- `p1g3` — Lenovo ThinkPad P1 Gen 3 (current primary)
- `t14s` — Lenovo ThinkPad T14s Gen 1 Intel (new primary)

## Testing Decisions

**Testing seam: NixOS build evaluation**
- Each phase is verified by `nixos-rebuild build --flake .#<hostname>` — if it builds, the module assembly is correct
- `nix flake check` validates flake structure, pre-commit hooks (nixfmt)
- No unit tests needed — the NixOS module system's type checking and option validation serve as the test harness
- Physical verification: deploy to P1 with `nixos-rebuild switch` after Phase 1 and Phase 3 to confirm the desktop environment works identically

**Modules tested (implicitly via build):**
- All modules are tested by inclusion in the P1 build through Phase 4
- T14s-specific modules (`intel-gpu.nix`, `monitors-t14s.nix`) tested in Phase 5 build
- Parametric WireGuard module tested on both hosts

**Prior art:** The existing `checks.${system}.pre-commit-check` (nixfmt) continues to validate formatting.

## Out of Scope

- Secrets management (sops-nix, age-encrypted secrets) — WireGuard configs remain as file paths referencing `/etc/wireguard/`
- Multiple users — single-user assumption (`useGlobalPkgs = true`, user `martin`)
- Darwin/macOS support — NixOS only
- Home Manager standalone mode — NixOS-flake-integrated only
- Automated deployment (deploy-rs, colmena) — manual `nixos-rebuild` for now
- Rolling back the refactor — the old structure can be recovered from git history but no rollback mechanism is planned
- Upgrading `system.stateVersion` — remains `24.11`
- Upgrading NixOS channel — remains `nixos-26.05` as stable, `nixos-unstable` for select packages

## Further Notes

- Documentation files (`docs/dendritic.md`, this PRD) serve as onboarding material for future agents working on this repository
- A separate "Dendritic pattern guide" document should be created to explain the pattern to new agents, covering: how modules register, how hosts assemble, how to add a new feature, how to add a new host
- The `to-issues` skill should be used after this PRD to break phases into individual issues/tickets
- The P1's LUKS UUID (`c63de383-b1b4-40e0-a155-8bd3c414edbb` in configuration.nix, `62448792-4cdf-403f-95b6-65056b32cae6` in hardware-configuration.nix) should remain in the P1's host-specific config and not be migrated to shared modules
- The T14s will have its own LUKS UUID determined at install time
