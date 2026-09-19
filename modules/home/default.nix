{ ... }:
{
  flake.homeModules.home.default =
    {
      pkgs,
      lib,
      inputs,
      options,
      ...
    }:

    {
      home.username = "martin";
      home.homeDirectory = "/home/martin";
      home.stateVersion = "24.11";

      imports = [
        inputs.lazyvim.homeManagerModules.default
        inputs.noctalia.homeModules.default
        ./parts/packages-home.nix
        ./parts/shell.nix
        ./parts/editors.nix
        ./parts/programs.nix
        ./parts/themes.nix
        ./parts/hyprlock-idle.nix
      ];

      wayland.windowManager.hyprland = {
        enable = true;
        configType = "hyprlang";
        systemd.variables = [ "--all" ];
        systemd.enable = false;
      };

      wayland.windowManager.hyprland.importantPrefixes =
        options.wayland.windowManager.hyprland.importantPrefixes.default
        ++ [
          "output"
        ];

      wayland.windowManager.hyprland.settings = {
        "$mod" = "SUPER";
        "$terminal" = "kitty";
        "$fileManager" = "thunar";
        "$backlight" = "intel_backlight";
        exec-once = [
          "systemctl --user start hyprpolkitagent"
        ];
        env = [
          "GSK_RENDERER=gl"
        ];
        monitorv2 = [
          {
            output = "desc:BOE 0x086E";
            mode = "highres";
            position = "0x0";
            scale = 1;
          }
          {
            output = "desc:Dell Inc. AW3423DWF BDC42S3";
            mode = "3440x1440@165";
            position = "auto-right";
            scale = 1;
            vrr = 1;
          }
          {
            output = "desc:Microstep MSI MAG241CR 0x000001DA";
            mode = "1920x1080@144";
            position = "auto-right";
            scale = 1;
          }
          {
            output = "";
            mode = "preferred";
            position = "auto";
            scale = 1;
          }
        ];
        general = {
          gaps_in = 0;
          gaps_out = 0;
          border_size = 1;
          layout = "scrolling";
        };
        render.new_render_scheduling = false;
        decoration = {
          rounding = 0;
          blur = {
            enabled = false;
            size = 3;
            passes = 1;
          };
          shadow.enabled = false;
        };
        animations = {
          enabled = true;
          animation = [
            "windows, 1, 4, default"
            "windowsOut, 1, 4, default, popin 80%"
            "border, 1, 5, default"
            "borderangle, 1, 4, default"
            "fade, 1, 4, default"
            "workspaces, 1, 3, default"
          ];
        };
        dwindle = {
          preserve_split = true;
        };
        scrolling = {
          column_width = 1.0;
        };
        device = [
          {
            name = ".*synps.*";
            accel_profile = "adaptive";
          }
          {
            name = ".*elan.*";
            accel_profile = "adaptive";
          }
        ];
        input = {
          kb_layout = "us,us,mk";
          kb_variant = "dvorak,,";
          kb_options = "caps:escape,grp:alt_space_toggle";
          follow_mouse = 1;
          touchpad = {
            disable_while_typing = true;
            natural_scroll = true;
            tap-to-click = true;
            scroll_factor = 1.0;
          };
          accel_profile = "flat";
          sensitivity = 0;
        };
        gesture = [
          "4, horizontal, workspace"
          "2, left, dispatcher, exec, ytool key XF86Back"
          "2, right, dispatcher, exec, ytool key XF86Forward"
        ];
        windowrulev = [
          "float,class:^(copyq)$"
          "move onscreen cursor,class:^(copyq)$"
          "suppressevent maximize, class:.*"
          "scrolltouchpad 2, class:^(kitty)$"
        ];
        bind = [
          "$mod, DELETE, exec, uwsm app -- hyprlock"
          "$mod ALT, DELETE, exit,"
          "$mod ALT CONTROL, DELETE, exec, systemctl reboot"
          "$mod ALT CONTROL SHIFT, DELETE, exec, systemctl poweroff"
          "$mod, Q, killactive,"
          "$mod, F, togglefloating,"
          "$mod, P, pseudo,"
          "$mod, X, layoutmsg, togglesplit"
          "$mod, left, movefocus, l"
          "$mod, H, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, L, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, K, movefocus, u"
          "$mod, down, movefocus, d"
          "$mod, J, movefocus, d"
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"
          "$mod SHIFT, H, movecurrentworkspacetomonitor, l"
          "$mod SHIFT, left, movecurrentworkspacetomonitor, l"
          "$mod SHIFT, L, movecurrentworkspacetomonitor, r"
          "$mod SHIFT, right, movecurrentworkspacetomonitor, r"
          "$mod, mouse_down, workspace, e+1"
          "$mod ALT, L, workspace, e+1"
          "$mod ALT, right, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"
          "$mod ALT, H, workspace, e-1"
          "$mod ALT, left, workspace, e-1"
          "$mod CTRL, L, layoutmsg, swapcol r"
          "$mod CTRL, right, layoutmsg, swapcol r"
          "$mod CTRL, H, layoutmsg, swapcol l"
          "$mod CTRL, left, layoutmsg, swapcol l"
          "$mod, R, layoutmsg, colresize +conf"
          "$mod SHIFT, E, exec, uwsm app -- $fileManager"
          "$mod SHIFT, RETURN, exec, uwsm app -- $terminal"
          "$mod, SPACE, exec, noctalia msg panel-toggle launcher"
          "$mod, PERIOD, exec, uwsm app -- rofimoji --action copy"
          "$mod, V, exec, noctalia msg panel-toggle clipboard"
          ", Print, exec, uwsm app -- hyprshot -m output --clipboard-only"
          "SHIFT, Print, exec, uwsm app -- hyprshot -m window --clipboard-only"
          "$mod SHIFT, Print, exec, uwsm app -- hyprshot -m region --clipboard-only"
          "$mod, grave, exec, noctalia msg panel-toggle control-center notifications"
          "$mod SHIFT, T, exec, uwsm app -- hyprpicker -a"
          "$mod, F1, exec, noctalia msg panel-toggle control-center audio"
          "$mod, B, exec, noctalia msg bar-hide"
          "$mod ALT, B, exec, noctalia msg bar-show"
        ];
        bindd = [
          "$mod, Tab, Change focus to next window, cyclenext,"
          "$mod, Tab, Bring it to the top, bringactivetotop,"
        ];
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
        bindl = [
          ", XF86AudioMute, exec, noctalia msg volume-mute"
          ", XF86AudioRaiseVolume, exec, noctalia msg volume-up"
          ", XF86AudioLowerVolume, exec, noctalia msg volume-down"
          ", XF86AudioPause, exec, playerctl play-pause"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86MonBrightnessDown, exec, noctalia msg brightness-down"
          ", XF86MonBrightnessUp, exec, noctalia msg brightness-up"
        ];
        bindel = [
          "$mod, XF86AudioLowerVolume, exec, playerctl volume 0.05-"
          "$mod, XF86AudioRaiseVolume, exec, playerctl volume 0.05+"
        ];
      };

      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        settings = {
          shell = {
            launch_apps_as_systemd_services = true;
          };
          bar = {
            main = {
              auto_hide = true;
              reserve_space = false;
            };
          };
        };
      };

      programs.home-manager.enable = true;
    };
}
