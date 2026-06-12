{ self, inputs, ... }:
{
  flake.nixosModules.hyprland-system =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      _module.args.inputs = inputs;

      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        withUWSM = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
    };
}
