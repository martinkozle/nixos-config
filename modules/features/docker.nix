{
  flake.nixosModules.docker =
    { config, pkgs, ... }:
    {
      virtualisation.docker.enable = true;
    };
}
