{
  description = "My NixOS flake";

  # `follows` rule: follow our nixpkgs for inputs that only ship modules/libs or
  # dev tooling (one nixpkgs copy instead of many). Never follow for inputs that
  # serve prebuilt packages from their own binary cache (hyprland, noctalia,
  # llm-agents): the cache is built against their own nixpkgs pin, so following
  # ours changes every hash and turns cache hits into local builds. lazyvim and
  # herdr-nix build packages against their own nixpkgs-unstable pin, so they are
  # left alone too.
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
    lazyvim.url = "github:pfassina/lazyvim-nix";
    llm-agents.url = "github:numtide/llm-agents.nix";
    herdr-nix.url = "github:herdrdev/herdr-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    import-tree.url = "github:vic/import-tree";
  };

  # Every file under modules/ is a flake-parts module (see docs/dendritic.md).
  # hardware-configuration.nix files are plain NixOS modules, imported by their
  # host file instead.
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      inputs.import-tree.matchNot ".*/hardware-configuration\\.nix" ./modules
    );
}
