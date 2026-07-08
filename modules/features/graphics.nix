{
  flake.nixosModules.graphics =
    { ... }:
    {
      hardware.graphics = {
        enable = true;
      };

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };
    };
}
