# Home Manager integration for user `martin`. The HM modules imported here are
# on for every host; features with an HM half (hyprland, noctalia, nvidia, …)
# add theirs through `home-manager.sharedModules` from their own file.
{ inputs, config, ... }:
let
  hm = config.flake.homeModules;
in
{
  flake.nixosModules.home = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.martin = {
        imports = [
          hm.packages
          hm.shell
          hm.editors
          hm.programs
          hm.themes
        ];
        home.stateVersion = "24.11";
        programs.home-manager.enable = true;
      };
    };
  };
}
