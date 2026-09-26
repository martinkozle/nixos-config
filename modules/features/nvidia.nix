{
  flake.nixosModules.nvidia =
    { config, pkgs, ... }:
    {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = true;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      hardware.nvidia.prime = {
        reverseSync.enable = true;
      };

      hardware.nvidia-container-toolkit.enable = true;

      home-manager.sharedModules = [
        {
          # CUDA build of OBS. Not in cache.nixos.org, so it compiles locally.
          programs.obs-studio.package = pkgs.obs-studio.override { cudaSupport = true; };
        }
      ];
    };
}
