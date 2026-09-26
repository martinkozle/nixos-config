# Noctalia v5 desktop shell (bar, launcher, notifications, control center,
# OSDs, lock screen, idle). Runs as a systemd user service.
{ inputs, config, ... }:
{
  flake.homeModules.noctalia = {
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      settings = {
        shell = {
          launch_apps_as_systemd_services = true;
          screenshot = {
            save_to_file = false;
            copy_to_clipboard = true;
          };
        };
        bar = {
          main = {
            auto_hide = true;
            reserve_space = false;
          };
        };
        idle = {
          behavior = {
            lock = {
              timeout = 105;
              action = "lock";
              enabled = true;
            };
            "screen-off" = {
              timeout = 110;
              action = "screen_off";
              enabled = true;
            };
            "kbd-backlight" = {
              timeout = 100;
              action = "command";
              command = "brightnessctl -sd rgb:kbd_backlight set 0";
              resume_command = "brightnessctl -rd rgb:kbd_backlight";
              enabled = true;
            };
          };
        };
        lockscreen = {
          enabled = true;
          blurred_desktop = true;
          blur_intensity = 0.5;
          tint_intensity = 0.3;
        };
      };
    };
  };

  flake.nixosModules.noctalia = {
    # The `cachix` branch of the input always points at a commit in this cache.
    # Only hits while the noctalia input does not `follows` our nixpkgs.
    nix.settings = {
      substituters = [ "https://noctalia.cachix.org/" ];
      trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
    };

    home-manager.sharedModules = [ config.flake.homeModules.noctalia ];
  };
}
