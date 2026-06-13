# Placeholder — replace with output of:
#   sudo nixos-generate-config --no-filesystem --dir /path/to/modules/hosts/t14s
{ lib, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-root";
    fsType = "ext4";
  };
}
