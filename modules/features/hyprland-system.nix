{ inputs, ... }:
{
  flake.nixosModules.hyprland-system =
    { pkgs, ... }:
    {
      _module.args.inputs = inputs;

      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };

      # Noctalia's user service is WantedBy=graphical-session.target, which a bare
      # Hyprland session never activates on its own. hyprland.conf (exec-once)
      # starts this target; its Requires= pulls graphical-session.target in, which
      # then starts Noctalia. Pattern from docs.noctalia.dev (Hyprland case).
      systemd.user.targets.hyprland-session = {
        description = "Hyprland Session Target";
        unitConfig = {
          Requires = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
      };
    };
}
