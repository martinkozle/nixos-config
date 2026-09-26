# Lenovo ThinkPad T14s Gen 1 (Intel i7-10510U, no dGPU).
{ inputs, config, ... }:
{
  flake.nixosConfigurations.t14s = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.nixosModules; [
      # The generic t14s profile covers only ThinkPad/laptop basics; the Intel
      # CPU/GPU module adds VA-API video decode (intel-media-driver) etc.
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14s
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      inputs.nixos-hardware.nixosModules.common-pc-ssd
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
      ai-tools
      greetd
      disks-t14s
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
