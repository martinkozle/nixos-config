{
  flake.nixosModules.services =
    { pkgs, ... }:
    {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };

      # Firmware updates (BIOS, EC, Thunderbolt, SSD, fingerprint reader) from
      # the Linux Vendor Firmware Service. Nothing installs on its own:
      # `fwupdmgr refresh && fwupdmgr get-updates`, then `fwupdmgr update`.
      services.fwupd.enable = true;

      services.gnome.gnome-keyring.enable = true;
      # gpg-agent is the SSH agent (enableSSHSupport below); gnome-keyring's
      # gcr-ssh-agent would otherwise run alongside it.
      services.gnome.gcr-ssh-agent.enable = false;

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
