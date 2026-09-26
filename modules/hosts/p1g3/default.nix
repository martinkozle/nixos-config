# Lenovo ThinkPad P1 Gen 3 (Intel + NVIDIA Optimus).
{ inputs, config, ... }:
{
  flake.nixosConfigurations.p1g3 = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.nixosModules; [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p1-gen3
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
      nvidia
      luks-p1g3
      touchpad-p1g3
      wireguard-p1g3
      home
      {
        networking.hostName = "p1g3";
        # Release this machine was first installed with. Never bump it.
        system.stateVersion = "24.11";
      }
    ];
  };
}
