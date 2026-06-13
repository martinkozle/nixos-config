{
  flake.nixosModules.luks-p1g3 =
    { ... }:
    {
      boot.initrd.luks.devices."luks-c63de383-b1b4-40e0-a155-8bd3c414edbb".device =
        "/dev/disk/by-uuid/c63de383-b1b4-40e0-a155-8bd3c414edbb";
    };
}
