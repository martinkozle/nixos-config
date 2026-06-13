{
  flake.nixosModules.power =
    { ... }:
    {
      powerManagement.enable = true;

      boot.swappiness = 100;
      boot.zramSwap.enable = true;

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
