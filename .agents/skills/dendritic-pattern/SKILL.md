---
name: dendritic-pattern
description: How this NixOS repository uses the Dendritic pattern (flake-parts + import-tree). Use when working on any `.nix` file under `modules/`, adding a new feature, adding a new host, or refactoring existing config. Also use when the user asks about module registration, host assembly, or how to structure NixOS modules in this repo. Make sure to trigger this skill whenever you're editing NixOS config in this project — even for simple changes like adding a package — since the Dendritic conventions affect where and how you make changes.
---

# Dendritic Pattern — This Repository

This NixOS config uses the **Dendritic pattern** built on `flake-parts` + `import-tree`. `docs/dendritic.md` has the background research and the reasoning behind each choice (including corrections to an earlier, wrong version of these rules).

## Core Idea

`flake.nix` only declares inputs and passes `./modules` to import-tree. **Every `.nix` file under `modules/` is a flake-parts module** (except `hardware-configuration.nix`, which import-tree skips). A file owns one feature and can contribute to NixOS, Home Manager, or both.

```
modules/
  flake/       parts.nix (systems, HM flake module), dev.nix (formatter, checks, devShell)
  hosts/<h>/   default.nix (defines nixosConfigurations.<h>), hardware-configuration.nix
  features/    flake.nixosModules.<name>, optionally with a flake.homeModules.<name> half
  home/        user-only config: flake.homeModules.<name>
```

## How Modules Register

The file is a function of the flake-parts module args (`inputs`, `config`, `self`, …) and returns what it contributes. The NixOS/HM modules it defines close over `inputs` lexically — no `specialArgs`, no `_module.args`:

```nix
{ inputs, ... }:
{
  flake.nixosModules.myfeature =
    { pkgs, ... }:
    {
      environment.systemPackages = [ inputs.foo.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    };
}
```

Names are flat and, by convention, equal to the filename: `modules/features/nvidia.nix` → `flake.nixosModules.nvidia`.

Inside the NixOS/HM module, `config` means the NixOS/HM config. If you need the flake-parts `config` (e.g. `config.flake.homeModules`), bind it outside first:

```nix
{ config, ... }:
let hm = config.flake.homeModules; in
{ flake.nixosModules.x = { ... }: { home-manager.sharedModules = [ hm.x ]; }; }
```

## Features With a Home Manager Half

A feature with both system and user config defines both in one file; its NixOS module pulls in the HM half, so hosts only ever list NixOS modules:

```nix
{ config, ... }:
{
  flake.homeModules.noctalia = { programs.noctalia.enable = true; /* … */ };

  flake.nixosModules.noctalia = {
    nix.settings.substituters = [ "https://noctalia.cachix.org/" ];   # the feature owns its cache
    home-manager.sharedModules = [ config.flake.homeModules.noctalia ];
  };
}
```

Host-dependent user config works the same way — e.g. `nvidia.nix` sets the CUDA build of OBS through `sharedModules`, so there is no `nvidiaEnabled` flag.

User-only config with no system side goes in `modules/home/<name>.nix` as `flake.homeModules.<name>` and is added to the `imports` list in `modules/features/home.nix` (which sets up Home Manager for user `martin` on every host).

## How Hosts Are Assembled

`modules/hosts/<host>/default.nix`:

```nix
{ inputs, config, ... }:
{
  flake.nixosConfigurations.t14s = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.nixosModules; [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14s
      ./hardware-configuration.nix
      base
      graphics
      # … every module this host uses, shared ones included …
      home
      {
        networking.hostName = "t14s";
        system.stateVersion = "24.11";
      }
    ];
  };
}
```

Every host lists all its modules explicitly — no extracted `sharedModules` list — so diffing two host files shows exactly what differs. Creating a feature file is not enough; add it to each host that needs it.

## Adding a Feature

1. Create `modules/features/<name>.nix` defining `flake.nixosModules.<name>` (plus `flake.homeModules.<name>` + `home-manager.sharedModules` if it has a user side).
2. `git add` it — flakes only see tracked files.
3. Add `<name>` to the module list of each host that needs it.

Host-specific features are named `<feature>-<hostname>.nix` (`luks-p1g3.nix`, `disks-t14s.nix`) and listed only in that host.

## Adding a Host

1. `modules/hosts/<name>/hardware-configuration.nix` from `nixos-generate-config --no-filesystem --dir modules/hosts/<name>/`.
2. `modules/hosts/<name>/default.nix` — copy an existing host file, change hostName, nixos-hardware profile, host-specific modules, and set `system.stateVersion` to the release it was installed with.

## Critical Conventions

- **`useGlobalPkgs = true`**: HM uses the system `pkgs`, so overlays in HM modules are ignored. Overlays go in a NixOS module (`nixpkgs.overlays`, see `base.nix`).
- **Unstable packages**: `pkgs.unstable.<name>` (overlay in `base.nix`). Never `import inputs.nixpkgs-unstable` in a module — each import instantiates nixpkgs again.
- **Binary caches** live in the feature that needs them (`nix.settings` in hyprland.nix, noctalia.nix, ai-tools.nix), not in flake `nixConfig` (the user isn't a trusted user, so flake-level substituters are ignored).
- **`follows`**: see the comment at the top of `flake.nix`. Never add `follows` to inputs that serve their own binary cache (hyprland, noctalia, llm-agents).
- **`hardware-configuration.nix` — never edit.** Host hardware tweaks go in `<feature>-<host>.nix`.

## Common Tasks

| Task | Where |
|------|-------|
| System package | `modules/features/packages-system.nix` |
| User package | `modules/home/packages.nix` |
| Hyprland keybinds/settings | `modules/features/hyprland.nix` (HM half) |
| Noctalia settings | `modules/features/noctalia.nix` |
| New service | new `modules/features/<service>.nix` + add to hosts |
| Overlay | NixOS module (`nixpkgs.overlays`) |

## Building

```bash
nixos-rebuild build --flake .#p1g3   # or .#t14s
nix flake check
nix fmt                              # nixfmt-tree over the whole repo
nh os switch                         # deploy on the current machine
```
