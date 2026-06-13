{ pkgs, ... }:

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
    flake = "/home/martin/nixos-config";
  };

  programs.firefox = {
    enable = true;
    configPath = "/home/martin/.config/mozilla/firefox";
  };

  programs.rofi = {
    theme = "Arc-Dark";
  };

  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      cudaSupport = true;
    };
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "DejaVu Sans Mono";
      size = 10;
    };
  };
}
