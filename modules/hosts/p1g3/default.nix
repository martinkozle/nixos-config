{ config, inputs, ... }:
{
  flake.nixosConfigurations.p1g3 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p1-gen3
      ./hardware-configuration.nix
      config.flake.nixosModules.base
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users.martin = config.flake.homeModules.home.default;
      }
    ];
  };
}
