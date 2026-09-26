{ inputs, ... }:
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      # Safety net for the 1 GiB ESP; nh clean (programs.nix) normally prunes first.
      boot.loader.systemd-boot.configurationLimit = 10;

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
      # Home Manager's ~/.zshrc runs compinit; skip the second, system-wide run.
      # System completions stay on fpath via /etc/zshenv.
      programs.zsh.enableGlobalCompInit = false;

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

      # `pkgs.unstable.<name>` for the few packages taken from nixpkgs-unstable.
      # Defined once here; Home Manager sees it too via useGlobalPkgs.
      nixpkgs.overlays = [
        (final: _: {
          unstable = import inputs.nixpkgs-unstable {
            inherit (final.stdenv.hostPlatform) system;
            config.allowUnfree = true;
          };
        })
      ];

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

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        # Feature-specific caches (hyprland, noctalia, numtide) live in their
        # feature modules.
        substituters = [ "https://nix-community.cachix.org/" ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
}
