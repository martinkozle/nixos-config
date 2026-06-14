---
title: "Cross-host config sync strategy"
status: pre-prd
type: improvement
priority: medium
created: 2026-06-14
---

## Problem

Two laptops (P1, T14s) share ~90% of NixOS-managed config but have non-declarative state that drifts:
- App configs with secrets (opencode.jsonc — API keys, MCP servers)
- Stateful app data (PrismLauncher instances/mods, OBS scenes)
- Identity artifacts (GPG key, SSH known_hosts)

Currently synced by ad-hoc `scp`. No automation, no version control for secrets, easy to forget.

## Current State (as of 2026-06-14)

**Transferred:**
- GPG key — one-time export/import (shared key, not synced)
- opencode config — one-time scp (bare config was on T14s, file copied manually)
- Documents/Audio/Videos → NAS (`/mnt/nas`)

**Not yet transferred:**
- OBS scenes (`~/.config/obs-studio`, 432K)
- PrismLauncher (`~/.local/share/PrismLauncher`, 1.9G)
- SSH `config` + `known_hosts` (small, one copy is fine)

## Decisions Needed

### 1. What to sync?

Not everything needs syncing. Categories:

| Category | Examples | Sync? |
|----------|----------|-------|
| Secrets + identity | opencode API keys, SSH config | Yes |
| Effortful state | OBS scenes, Minecraft instances | Yes |
| Re-downloadable | LazyVim, editor plugins | No — apps handle it |
| Re-auth required | Signal, browser profiles, Vesktop | No — per-machine |
| Machine-specific | Hyprland state, dconf | No — NixOS manages it |

### 2. Sync mechanism

Options considered:
- **Syncthing** — peer-to-peer, zero config, secrets stay local. Best for `~/.config/opencode/` and `~/.local/share/PrismLauncher/`
- **Nix + agenix/sops-nix** — fully declarative, encrypted secrets in git. Heavy setup for 2 machines
- **mkOutOfStoreSymlink** — configs live in repo, HM symlinks to git checkout. Hot-reload but secrets need sops-nix anyway
- **Manual scp** — current approach, works but unreliable

Tentative: Syncthing for directories with secrets, Nix for everything else.

### 3. Where does the "source of truth" live?

For synced dirs, one machine is canonical (P1 for now). T14s receives. No bidirectional sync — avoids conflicts.

### 4. Should secrets be in Nix?

opencode.jsonc has API keys (EXA, Context7). Options:
- Keep as raw file synced via Syncthing (simple, secrets off git)
- Move to Nix with agenix/sops-nix (declarative, encrypted in git)
- Use env vars referenced from Nix-managed config (split secrets from structure)

Question for grill: is the overhead of sops-nix worth it for 2 API keys and 1 config file?

## Open Questions

- Syncthing: NixOS service or user-space? Both machines need it running
- Should opencode config be split into "structure" (Nix) + "secrets" (Syncthing/env vars)?
- PrismLauncher: 1.9G is large for Syncthing initial sync. Worth it vs re-downloading mods?
- OBS scenes: small, one scp is fine. Sync only if scenes change often

## Rough Scope

If we go Syncthing:
1. Install Syncthing on both hosts (NixOS service or HM module)
2. Configure shared folders: `~/.config/opencode/`, `~/.local/share/PrismLauncher/`
3. Set P1 as master, T14s as receive-only
4. Document the setup in AGENTS.md

If we go sops-nix:
1. Add sops-nix input + age key per host
2. Encrypt opencode.jsonc (or extract secrets into .age files)
3. Wire secrets into Nix-managed config via environment variables
4. Remove Syncthing dependency

## Out of Scope

- macOS/Darwin sync (NixOS only)
- Bidirectional sync (single source of truth)
- Syncing browser data, chat apps, anything requiring re-auth
