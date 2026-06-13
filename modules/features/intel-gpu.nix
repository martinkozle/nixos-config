{
  flake.nixosModules.intel-gpu =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      boot.kernelModules = [ "i915" ];

      hardware.enableRedistributableFirmware = lib.mkDefault true;

      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
