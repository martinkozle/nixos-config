{ ... }:
{
  flake.nixosModules.p1g3 =
    { ... }:
    {
      imports = [
        ./hardware-configuration.nix
      ];
    };
}
