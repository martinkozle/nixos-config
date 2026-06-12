{
  flake.nixosModules.graphics =
    { config, pkgs, ... }:
    {
      hardware.graphics = {
        enable = true;
      };

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };
    };
}
