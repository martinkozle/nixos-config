{
  flake.nixosModules.disks-t14s = {
    # Root (declared in hardware-configuration.nix). allowDiscards lets TRIM pass
    # through LUKS to the SSD; costs only revealing which blocks are unused.
    boot.initrd.luks.devices."luks-8be7d7a8-ad1d-443e-8030-429a1e291ee5".allowDiscards = true;

    # nvme0n1p3 (8.8 GiB) was an installer LUKS swap partition that was never
    # opened. Use it as overflow swap behind zram, re-encrypted with a random key
    # every boot: no passphrase, no hibernation. Addressed by PARTUUID because
    # the reformat changes the filesystem UUID on every boot.
    swapDevices = [
      {
        device = "/dev/disk/by-partuuid/ee98f31d-3a00-45ea-854e-d362e14567a6";
        randomEncryption = {
          enable = true;
          allowDiscards = true;
        };
        # Below zram (priority 5), so it is only used once zram is full.
        priority = 1;
      }
    ];
  };
}
