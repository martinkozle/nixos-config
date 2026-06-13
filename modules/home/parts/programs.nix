{
  pkgs,
  homeDirectory,
  nvidiaEnabled ? false,
  ...
}:

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
    flake = "${homeDirectory}/nixos-config";
  };

  programs.firefox = {
    enable = true;
    configPath = "${homeDirectory}/.config/mozilla/firefox";
  };

  programs.rofi = {
    theme = "Arc-Dark";
  };

  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      cudaSupport = nvidiaEnabled;
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
