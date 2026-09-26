{
  flake.nixosModules.power =
    { ... }:
    {
      powerManagement.enable = true;

      zramSwap.enable = true;

      # Values recommended for zram: swapping to compressed RAM is cheap, so
      # swap eagerly, and read one page at a time (no readahead).
      boot.kernel.sysctl = {
        "vm.swappiness" = 180;
        "vm.page-cluster" = 0;
      };

      services.thermald.enable = true;

      services.upower.enable = true;

      services.tlp = {
        enable = true;

        settings = {
          INTEL_GPU_MIN_FREQ_ON_AC = 500;
          START_CHARGE_THRESH_BAT0 = 75;
          STOP_CHARGE_THRESH_BAT0 = 80;
        };
      };
    };
}
