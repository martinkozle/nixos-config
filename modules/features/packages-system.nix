{
  flake.nixosModules.packages-system =
    { config, pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.vim
        pkgs.wget
        pkgs.curl
        pkgs.tmux
        pkgs.gnupg
        pkgs.pinentry-qt
        pkgs.libsecret
      ];
    };
}
