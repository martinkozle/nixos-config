{ inputs, ... }:
{
  # Declares `flake.homeModules` as a mergeable attrset of modules, so any file
  # can contribute `flake.homeModules.<name>` just like `flake.nixosModules`.
  imports = [ inputs.home-manager.flakeModules.home-manager ];

  systems = [ "x86_64-linux" ];
}
