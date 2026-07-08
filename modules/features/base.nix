{ inputs, ... }:
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      _module.args.inputs = inputs;

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];

      time.timeZone = "Europe/Skopje";

      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "mk_MK.UTF-8";
        LC_IDENTIFICATION = "mk_MK.UTF-8";
        LC_MEASUREMENT = "mk_MK.UTF-8";
        LC_MONETARY = "mk_MK.UTF-8";
        LC_NAME = "mk_MK.UTF-8";
        LC_NUMERIC = "mk_MK.UTF-8";
        LC_PAPER = "mk_MK.UTF-8";
        LC_TELEPHONE = "mk_MK.UTF-8";
        LC_TIME = "mk_MK.UTF-8";
      };

      environment.shells = [ pkgs.zsh ];
      users.defaultUserShell = pkgs.zsh;
      programs.zsh.enable = true;

      services.xserver.xkb = {
        layout = "us";
        variant = "dvorak";
      };

      console.keyMap = "dvorak";

      users.users.martin = {
        isNormalUser = true;
        description = "Martin Popovski";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        packages = [ ];
      };

      nixpkgs.config.allowUnfree = true;

      environment.pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];

      fonts = {
        fontDir.enable = true;
        packages = [
          pkgs.monaspace
          pkgs.nerd-fonts.monaspace
        ];
      };

      programs.nix-ld.enable = true;

      system.stateVersion = "24.11";

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters = [
          "https://nix-community.cachix.org/"
          "https://hyprland.cachix.org/"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
      };
    };
}
