{
  flake.nixosModules.services =
    { config, pkgs, ... }:
    {
      services.openssh.enable = true;

      services.gnome.gnome-keyring.enable = true;

      programs.seahorse.enable = true;

      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-qt;
        enableSSHSupport = true;
      };

      programs.ydotool.enable = true;

      programs.localsend.enable = true;
    };
}
