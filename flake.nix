{
  description = "My NixOS flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    git-hooks.url = "github:cachix/git-hooks.nix";
    lazyvim.url = "github:pfassina/lazyvim-nix";
    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        (inputs.import-tree.matchNot ".*hardware-configuration.*" ./modules)
      ];

      flake = {
        schemas = {
          checks = inputs.flake-parts.flakeSchema.applyCheckSchema;
        };
      };

      perSystem =
        {
          pkgs,
          self',
          ...
        }:
        {
          formatter = pkgs.nixfmt;

          checks.pre-commit-check = inputs.git-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
            src = ./.;
            hooks = {
              nixfmt.enable = true;
            };
          };

          devShells.default =
            let
              inherit (self'.checks.pre-commit-check) shellHook enabledPackages;
            in
            pkgs.mkShell {
              inherit shellHook;
              buildInputs = enabledPackages;
            };
        };
    };
}
