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
          # Give up after 10s instead of hanging when the NAS is unreachable,
          # and unmount after 10 min idle so a later network change is safe.
          "x-systemd.mount-timeout=10s"
          "x-systemd.idle-timeout=10min"
        ];
      };
    };
}
