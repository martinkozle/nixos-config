{
  flake.nixosModules.luks-p1g3 = {
    # Root (declared in hardware-configuration.nix). allowDiscards lets TRIM pass
    # through LUKS to the SSD; costs only revealing which blocks are unused.
    boot.initrd.luks.devices."luks-62448792-4cdf-403f-95b6-65056b32cae6".allowDiscards = true;

    # Second LUKS device, unlocked but currently unused (likely the installer's
    # swap). See docs/p1g3-on-device.md before using or removing it.
    boot.initrd.luks.devices."luks-c63de383-b1b4-40e0-a155-8bd3c414edbb" = {
      device = "/dev/disk/by-uuid/c63de383-b1b4-40e0-a155-8bd3c414edbb";
      allowDiscards = true;
    };
  };
}
