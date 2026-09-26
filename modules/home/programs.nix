{
  flake.homeModules.programs =
    { config, pkgs, ... }:
    {
      programs.git = {
        enable = true;
        package = pkgs.gitFull;
        lfs.enable = true;
        settings = {
          init.defaultBranch = "main";
          user.email = "martinkozle@yahoo.com";
          user.name = "Martin Popovski";
        };
        signing.key = "847633C95FC29494";
        signing.signByDefault = true;
      };

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep 5 --keep-since 7d";
        flake = "${config.home.homeDirectory}/nixos-config";
      };

      # Two-finger swipe back/forward (macOS style) is done by the browsers
      # themselves: Firefox has it on by default on Wayland, Chromium-based
      # browsers need this feature flag.
      programs.firefox = {
        enable = true;
        configPath = "${config.home.homeDirectory}/.config/mozilla/firefox";
      };

      programs.chromium = {
        enable = true;
        commandLineArgs = [ "--enable-features=TouchpadOverscrollHistoryNavigation" ];
      };

      programs.brave = {
        enable = true;
        commandLineArgs = [ "--enable-features=TouchpadOverscrollHistoryNavigation" ];
      };

      # NVENC/CUDA build is set by the nvidia feature (modules/features/nvidia.nix).
      programs.obs-studio.enable = true;

      programs.kitty = {
        enable = true;
        font = {
          name = "DejaVu Sans Mono";
          size = 10;
        };
      };
    };
}
