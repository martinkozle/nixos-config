# Lenovo ThinkPad T14s Gen 1 (Intel i7-10510U, no dGPU).
{ inputs, config, ... }:
{
  flake.nixosConfigurations.t14s = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.nixosModules; [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14s
      ./hardware-configuration.nix
      base
      graphics
      networking
      nfs
      audio
      bluetooth
      docker
      services
      security
      power
      packages-system
      hyprland
      noctalia
      greetd
      intel-gpu
      wireguard-t14s
      home
      {
        networking.hostName = "t14s";
        # Release this machine was first installed with. Never bump it.
        system.stateVersion = "24.11";
      }
    ];
  };
}
