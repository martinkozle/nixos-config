{
  config,
  ...
}:
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
        (import ./parts/packages-home.nix { inherit pkgs inputs; })
        (import ./parts/shell.nix { inherit pkgs config; })
        (import ./parts/editors.nix { inherit pkgs inputs; })
        (import ./parts/programs.nix { inherit pkgs config; })
        (import ./parts/themes.nix { inherit pkgs; })
        (import ./parts/waybar.nix { })
        (import ./parts/hyprlock-idle.nix { inherit lib; })
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
          "uwsm app -- wl-paste --type text --watch cliphist store"
          "uwsm app -- wl-paste --type image --watch cliphist store"
          "uwsm app -- blueman-tray"
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
            name = "synps/2-synaptics-touchpad";
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
          "$mod, SPACE, exec, uwsm app -- rofi -show drun"
          "$mod, PERIOD, exec, uwsm app -- rofimoji --action copy"
          "$mod, V, exec, cliphist list | uwsm app -- rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons"
          ", Print, exec, uwsm app -- hyprshot -m output --clipboard-only"
          "SHIFT, Print, exec, uwsm app -- hyprshot -m window --clipboard-only"
          "$mod SHIFT, Print, exec, uwsm app -- hyprshot -m region --clipboard-only"
          "$mod, grave, exec, uwsm app -- swaync-client -t -sw"
          "$mod SHIFT, T, exec, uwsm app -- hyprpicker -a"
          "$mod, F1, exec, uwsm app -- pavucontrol"
          "$mod, B, exec, killall -s SIGUSR1 .waybar-wrapped || uwsm app -- waybar"
          "$mod ALT, B, exec, killall .waybar-wrapped"
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
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; hyprctl notify -1 1500 0 $(wpctl get-volume @DEFAULT_AUDIO_SINK@)"
          ", XF86AudioPause, exec, playerctl play-pause; hyprctl notify -1 2000 0 \"$(playerctl metadata xesam:title) - $(playerctl metadata xesam:artist) ($(playerctl status))\""
          ", XF86AudioPlay, exec, playerctl play-pause; hyprctl notify -1 2000 0 \"$(playerctl metadata xesam:title) - $(playerctl metadata xesam:artist) ($(playerctl status))\""
          ", XF86AudioNext, exec, playerctl next; hyprctl notify -1 3000 0 \"$(playerctl metadata xesam:title) - $(playerctl metadata xesam:artist)\""
          ", XF86AudioPrev, exec, playerctl previous; hyprctl notify -1 3000 0 \"$(playerctl metadata xesam:title) - $(playerctl metadata xesam:artist)\""
        ];
        bindel = [
          ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-; hyprctl notify -1 1500 0 $(wpctl get-volume @DEFAULT_AUDIO_SINK@)"
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+; hyprctl notify -1 1500 0 $(wpctl get-volume @DEFAULT_AUDIO_SINK@)"
          "$mod, XF86AudioLowerVolume, exec, playerctl volume 0.05-; hyprctl notify -1 1500 0 \"$(playerctl metadata xesam:title) - $(playerctl metadata xesam:artist) ($(playerctl volume))\""
          "$mod, XF86AudioRaiseVolume, exec, playerctl volume 0.05+; hyprctl notify -1 1500 0 \"$(playerctl metadata xesam:title) - $(playerctl metadata xesam:artist) ($(playerctl volume))\""
          ", XF86MonBrightnessDown, exec, brightnessctl -d $backlight set 5%- --min-value 1; hyprctl notify -1 1500 0 \"Brightness: $(brightnessctl -d $backlight -m | cut -d, -f4)\""
          ", XF86MonBrightnessUp, exec, brightnessctl -d $backlight set 5%+; hyprctl notify -1 1500 0 \"Brightness: $(brightnessctl -d $backlight -m | cut -d, -f4)\""
        ];
      };

      services.swaync = {
        enable = true;
      };

      services.network-manager-applet.enable = true;
      services.blueman-applet.enable = true;

      programs.home-manager.enable = true;
    };
}
