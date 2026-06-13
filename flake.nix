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
    let
      fp = inputs.flake-parts.lib.mkFlake { inherit inputs; };
      flake = fp {
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
          { pkgs, self', ... }:
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

      # Inline module loading — handles both { ... } and {} module signatures
      loadFeature =
        path: name:
        let
          raw = import path;
          loaded = if builtins.isFunction raw then raw { inherit inputs; } else raw;
        in
        loaded.flake.nixosModules.${name};
    in
    flake
    // {
      nixosConfigurations = {
        p1g3 = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p1-gen3
            ./modules/hosts/p1g3/hardware-configuration.nix
            (loadFeature ./modules/features/base.nix "base")
            (loadFeature ./modules/features/graphics.nix "graphics")
            (loadFeature ./modules/features/networking.nix "networking")
            (loadFeature ./modules/features/nfs.nix "nfs")
            (loadFeature ./modules/features/audio.nix "audio")
            (loadFeature ./modules/features/bluetooth.nix "bluetooth")
            (loadFeature ./modules/features/docker.nix "docker")
            (loadFeature ./modules/features/services.nix "services")
            (loadFeature ./modules/features/security.nix "security")
            (loadFeature ./modules/features/power.nix "power")
            (loadFeature ./modules/features/packages-system.nix "packages-system")
            (loadFeature ./modules/features/hyprland-system.nix "hyprland-system")
            (loadFeature ./modules/features/nvidia.nix "nvidia")
            (loadFeature ./modules/features/luks-p1g3.nix "luks-p1g3")
            (loadFeature ./modules/features/wireguard-p1g3.nix "wireguard-p1g3")
            inputs.home-manager.nixosModules.home-manager
            {
              networking.hostName = "p1g3";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.martin = flake.homeModules.home.default;
            }
          ];
        };
      };
    };
}
