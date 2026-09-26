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
          # CUDA build of OBS. Not in cache.nixos.org, so it compiles locally;
          # see docs/p1g3-on-device.md before changing.
          programs.obs-studio.package = pkgs.obs-studio.override { cudaSupport = true; };

          # Added Jan 2025 when GTK 4's new renderer misbehaved. Kept on the P1
          # only until retested there (docs/p1g3-on-device.md).
          wayland.windowManager.hyprland.settings.env = [ "GSK_RENDERER=gl" ];
        }
      ];
    };
}
