{
  flake.nixosModules.nfs =
    { ... }:
    {
      fileSystems."/mnt/nas" = {
        device = "debian:/nas";
        fsType = "nfs";
        options = [
          "x-systemd.automount"
          "noauto"
          "nofail"
        ];
      };
    };
}
