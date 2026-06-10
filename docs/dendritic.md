## NixOS Multi-Host Configuration Patterns — Research Report

### 1. The Dendritic Pattern

**Core idea:** Every `.nix` file (except `flake.nix` and entry points) is a **flake-parts top-level module**. Each file implements a single **feature/aspect** (e.g., "nvidia", "docker", "hyprland") and contributes to **multiple configuration classes simultaneously** (`flake.modules.nixos`, `flake.modules.homeManager`, `flake.modules.darwin`) from one file.

**Key mechanism:** `flake-parts` with `import-tree` auto-discovers all `.nix` files under `modules/`. Modules register themselves into a catalog namespace (`flake.modules.nixos.<name>`) as `deferredModule` types, which merge automatically. Hosts then pick what they need via `imports`.

**Canonical structure:**
```
flake.nix                          # 10 lines — delegates to flake-parts
modules/
  features/
    nvidia.nix                     # ONE file owns nvidia across nixos + home-manager
    hyprland.nix
    docker.nix
    ...
  hosts/
    p1g3/
      default.nix                  # declares nixosConfigurations.p1g3, imports modules
      hardware-configuration.nix
    other-laptop/
      default.nix
      hardware-configuration.nix
```

**A module file looks like:**
```nix
{ self, ... }: {
  flake.nixosModules.nvidia = { pkgs, ... }: {
    hardware.nvidia = { modesetting.enable = true; /* ... */ };
  };
  flake.homeModules.nvidia = { ... }: {
    # home-manager side of nvidia config
  };
}
```

**Host file reads like a menu:**
```nix
{ top, ... }: {
  flake.nixosModules.p1g3 = { config, ... }: {
    imports = with top.config.flake.nixosModules; [
      base
      nvidia
      hyprland
      wireguard
    ];
  };
}
```

**Pros:**
- **True cross-cutting** — one file owns a feature across NixOS + Home-Manager + Darwin
- **No `specialArgs` spaghetti** — every file reads from the same top-level `config`
- **Auto-discovery** — adding a module is just creating a file
- **Host configs are declarative menus** — trivial to diff between hosts
- **Scales** — used successfully with 100+ modules
- **File path = feature name** — files are freely movable/renameable

**Cons:**
- **Steep learning curve** — requires understanding flake-parts, `deferredModule`, the module system deeply
- **Overkill for single-host** — if you only have one machine, the standard approach is simpler
- **Slower `flake check`** — evaluates the entire module tree
- **Debugging requires different tools** — `nixos-option` instead of `grep -r`

---

### 2. VimJoyer's Approach

VimJoyer uses a **Dendritic-inspired flake-parts pattern** (he's an advocate and has videos on it). His structure (`nixconf` repo, `flake-parts-wrapped-template`):

```
flake.nix                          # ~20 lines, uses import-tree
modules/
  hosts/
    myMachine/
      default.nix                  # declares nixosConfigurations.myMachine
      configuration.nix            # host's nixosModules (imports features)
      hardware.nix
  features/
    niri.nix                       # wraps niri WM, uses perSystem + nixosModules
    noctalia.nix
    ...
```

**Key characteristics:**
- Uses `flake.nixosModules.<name>` for NixOS modules, `flake.homeModules.<name>` for Home-Manager
- Uses `perSystem` for custom packages (wrappers, etc.)
- Uses `wrapper-modules` for wrapping programs with custom settings
- Uses `flake-file` for declarative flake inputs per-module
- Uses `hjem` for dotfile management (alternative to home-manager's `home.file`)
- Host configs are thin — they assemble modules from `self.nixosModules`
- His [Video 79](https://www.vimjoyer.com/vid79-parts-wrapped) walks through the full setup

**It's essentially the Dendritic pattern with his own toolchain preferences** (wrapper-modules, hjem, flake-file).

---

### 3. Other Popular Multi-Host Patterns

**A. Standard `hosts/` + `base.nix` (most common)**
```
flake.nix                          # explicit nixosConfigurations per host
configuration.nix                  # shared base: users, nix settings, home-manager bootstrap
modules/
  common/                          # shared modules
  host-specific/
hosts/
  laptop/
    default.nix                    # imports base + hardware + host-specific modules
    hardware-configuration.nix
  desktop/
    default.nix
    hardware-configuration.nix
```
- Simple, no flake-parts dependency
- `flake.nix` grows with each host (repetitive `nixosSystem` blocks)
- Home-manager config lives separately (often in `home/` directory)
- Good for 2-5 hosts, gets unwieldy beyond that

**B. Profile-based (e.g., Bomba pattern)**
```
modules/
  profiles/
    base.nix        # all hosts
    graphical.nix   # desktops/laptops with GUI
    server.nix      # headless
hosts/
  laptop/configuration.nix   # imports base.nix + graphical.nix
  desktop/configuration.nix  # imports base.nix + graphical.nix
```
- Hosts import profiles, profiles aggregate modules
- Clean separation of concerns
- Still requires `flake.nix` to enumerate hosts

**C. `nixos-facter-modules` driven (Gunwant Jain pattern)**
- Host metadata declared as a data structure
- `mkHost` function generates configurations
- Good for large fleets, overkill for 2 hosts

---

### 4. Recommendation for Your Case

**Your situation:** 2 laptops, ~90% shared config (Hyprland, same user, same packages), diverging on NVIDIA vs Intel GPU, monitor config, LUKS UUIDs, WireGuard, NFS, TLP.

**I recommend: Dendritic pattern (flake-parts + import-tree)**

**Why it fits your case best:**

1. **90% shared / 10% divergent is the ideal Dendritic use case** — shared features (hyprland, packages, shell, etc.) are modules that both hosts import; divergent features (nvidia, monitor configs, luks) are separate modules that only one host imports

2. **NVIDIA isolation** — `modules/features/nvidia.nix` gets imported only by `p1g3`. The second laptop's host file simply doesn't import it. No `if/else`, no conditional logic baked into shared code.

3. **Home-Manager + NixOS in one file** — for something like Hyprland, the NixOS side (services, packages) and Home-Manager side (config files, keybinds) live in the same `hyprland.nix`. When you modify Hyprland config, you're in one place.

4. **Adding the second laptop is trivial** — just add `hosts/laptop2/default.nix` + `hardware-configuration.nix`, list the modules it needs. Diff the two host files and you'll see the delta clearly.

5. **You're already on flakes + home-manager** — the migration path is cleaner than starting from scratch.

**Suggested migration target:**
```
flake.nix                              # ~15 lines, delegates to import-tree
modules/
  features/
    nvidia.nix                         # p1g3 only
    hyprland.nix                       # shared
    wireguard.nix                      # p1g3 only (or parametric)
    monitors-p1g3.nix                  # p1g3 only
    tlp-intel.nix                      # laptop2 only
    nfs.nix                            # p1g3 only
    base.nix                           # shared: users, locale, time, nix settings
    packages.nix                       # shared packages
    shell.nix                          # shared fish/zsh config
    audio.nix                          # shared pipewire
    networking.nix                     # shared networkmanager
  home/
    general.nix                        # shared HM: editor, terminal, git
    hyprland.nix                       # shared HM: hyprland config files
  hosts/
    p1g3/
      default.nix                      # imports: base, nvidia, hyprland, wireguard, monitors-p1g3, nfs
      hardware-configuration.nix
    laptop2/
      default.nix                      # imports: base, hyprland, tlp-intel, monitors-laptop2
      hardware-configuration.nix
```

**What to do with the ~90% shared config:** Extract it into `base.nix`, `packages.nix`, `shell.nix`, etc. These become modules both hosts import. The host files become thin assembly files — 20-30 lines each, listing what modules to import.

**Migration approach:** Don't do it all at once. Start with:
1. Set up `flake.nix` with flake-parts + import-tree
2. Move `configuration.nix` content into `modules/features/base.nix`
3. Extract NVIDIA into its own module
4. Extract home-manager into `modules/home/` modules
5. Create `hosts/p1g3/default.nix` that imports everything
6. Verify it builds
7. Then add `hosts/laptop2/` when you're ready

This is the approach with the best long-term maintainability for your 2-host, high-overlap scenario.