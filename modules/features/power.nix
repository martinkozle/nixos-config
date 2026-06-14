{
  flake.nixosModules.power =
    { ... }:
    {
      powerManagement.enable = true;

      zramSwap.enable = true;

      boot.kernel.sysctl."vm.swappiness" = 100;

      services.thermald.enable = true;

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
