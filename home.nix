{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:

let
  myAliases = {
    ll = "ls -l";
  };

  scriptDir = ./scripts;
  scriptFiles = builtins.attrNames (builtins.readDir scriptDir);

  scriptBins = builtins.map (
    name: pkgs.writeShellScriptBin name (builtins.readFile (scriptDir + "/${name}"))
  ) scriptFiles;
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "martin";
  home.homeDirectory = "/home/martin";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  nixpkgs.config.allowUnfree = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.killall
    pkgs.clang
    pkgs.rofi-wayland
    pkgs.rofimoji
    pkgs.cliphist
    pkgs.wl-clipboard
    pkgs.hyprshot
    pkgs.hyprpolkitagent
    pkgs.hyprpicker
    pkgs.brightnessctl
    pkgs.playerctl
    pkgs.pavucontrol
    pkgs.brave
    pkgs.joplin-desktop
    pkgs.btop
    pkgs.seahorse
    pkgs.vscode.fhs
    pkgs.nixfmt-rfc-style
    pkgs.nixd
    pkgs-unstable.uv
    pkgs.aoc-cli
    pkgs.xfce.thunar
    pkgs.xfce.thunar-volman
    pkgs.xfce.thunar-archive-plugin
    pkgs.xfce.thunar-media-tags-plugin
    pkgs-unstable.godot_4
    pkgs.vesktop
    pkgs.helio-workstation
    pkgs.pre-commit
    pkgs.audacity
    pkgs.shotcut
    pkgs.vlc
    pkgs.unzip
    pkgs.libsForQt5.okular
    pkgs.cargo
    pkgs.rustc
    pkgs.networkmanagerapplet
    pkgs.libreoffice-fresh
    pkgs.hunspell
    pkgs.hunspellDicts.en_US
    pkgs.teams-for-linux
    pkgs.signal-desktop
    pkgs.gnumake
    pkgs.cmake
  ] ++ scriptBins;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/martin/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Sans";
      size = 11;
    };
  };

  nixGL.vulkan.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = myAliases;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = myAliases;
    history = {
      size = 100000;
      path = "${config.xdg.dataHome}/zsh/zsh_history";
    };

    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];

    initContent = ''
      if uwsm check may-start && uwsm select; then
      	exec systemd-cat -t uwsm_start uwsm start default
      fi
    '';
  };

  programs.starship = {
    enable = true;
    settings = { };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    extraConfig = {
      credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
      init.defaultBranch = "main";
    };
    signing.key = "847633C95FC29494";
    signing.signByDefault = true;
    userName = "Martin Popovski";
    userEmail = "martinkozle@yahoo.com";
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  programs.rofi = {
    theme = "Arc-Dark";
  };

  # TODO: Remove eventually. Issue: https://github.com/nix-community/home-manager/issues/5899
  systemd.user.services.hypridle.Unit.After = lib.mkForce "graphical-session.target";

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };

      listener = [
        {
          timeout = 100;
          on-timeout = "brightnessctl -s set 10";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 100;
          on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0";
          on-resume = "brightnessctl -rd rgb:kbd_backlight";
        }
        {
          timeout = 105;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 110;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 1;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "<span foreground=\"##cad3f5\">Password...</span>";
          shadow_passes = 2;
        }
      ];
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 40;
        mode = "hide";
        modules-left = [
          "hyprland/workspaces"
          "cpu"
          "memory"
          "temperature"
          "disk"
        ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "nm-applet"
          "blueman-applet"
          "pulseaudio"
          "backlight"
          "battery"
          "clock"
          "keyboard-state"
          "tray"
        ];

        "hyprland/workspaces" = {
          separate-outputs = true;
        };
      };
    };
    style = ''
      window#waybar {
        background-color: rgba(0, 0, 0, 1.0);
        color: #ffffff;
      }

      #workspaces button.focused {
        background-color: #64727D;
      }

      #workspaces button.urgent {
        background-color: #eb4d4b;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #temperature,
      #disk,
      #backlight,
      #network,
      #pulseaudio,
      #custom-media,
      #tray,
      #mode,
      #mpd {
          padding: 0 10px;
          margin: 6px 3px; 
          color: #000000;
      }

      #window,
      #workspaces {
          margin: 0 4px;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }

      #clock {
        background-color: #000000;
        color: white;
      }

      #battery {
        background-color: #000000;
        color: white;
      }

      #battery.charging {
        color: #ffffff;
        background-color: #000000;
      }

      @keyframes blink {
        to {
          background-color: #ffffff;
          color: #000000;
        }
      }

      #battery.critical:not(.charging) {
        background-color: #f53c3c;
        color: #ffffff;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      label:focus {
        background-color: #000000;
      }

      #cpu {
        background-color: #000000;
        color: #ffffff;
      }

      #memory {
        background-color: #000000;
        color: white;
      }

      #disk {
        background-color: #000000;
        color: white;
      }

      #backlight {
        background-color: #000000;
        color:white;
      }

      #network {
        background-color: #000000;
        color:white;
      }

      #network.disconnected {
        background-color: #f53c3c;
      }

      #pulseaudio {
        background-color: #000000;
        color: #ffffff;
      }

      #pulseaudio.muted {
        background-color: #000000;
        color: #ffffff;
      }

      #custom-media {
        background-color: #66cc99;
        color: #2a5c45;
        min-width: 100px;
      }

      #custom-media.custom-spotify {
        background-color: #66cc99;
      }

      #custom-media.custom-vlc {
        background-color: #ffa000;
      }

      #temperature {
        background-color: #f0932b;
      }

      #temperature.critical {
        background-color: #eb4d4b;
      }

      #tray {
        background-color: #2980b9;
      }

      #mpd {
        background-color: #66cc99;
        color: #2a5c45;
      }

      #mpd.disconnected {
        background-color: #f53c3c;
      }

      #mpd.stopped {
        background-color: #90b1b1;
      }

      #mpd.paused {
        background-color: #51a37a;
      }

      #language {
        background: #bbccdd;
        color: #333333;
        padding: 0 5px;
        margin: 6px 3px;
        min-width: 16px;
      }
    '';
  };

  services.swaync = {
    enable = true;
  };

  services.network-manager-applet.enable = true;
  services.blueman-applet.enable = true;

  programs.kitty.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.variables = [ "--all" ];
    systemd.enable = false;
  };

  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    "$terminal" = "kitty";
    "$fileManager" = "thunar";
    "$backlight" = "intel_backlight";
    # debug.disable_logs = false;
    # debug.overlay = true;
    exec-once = [
      "systemctl --user start hyprpolkitagent"
      "uwsm app -- wl-paste --type text --watch cliphist store"
      "uwsm app -- wl-paste --type image --watch cliphist store"
      "uwsm app -- blueman-tray"
    ];
    env = [
      "GSK_RENDERER,gl"
    ];
    monitor = [
      "desc:BOE 0x086E,highres,0x0,1"
      "desc:Dell Inc. AW3423DWF BDC42S3,3440x1440@100,auto-right,1,vrr,1"
      "desc:Microstep MSI MAG241CR 0x000001DA,1920x1080@60,auto-right,1"
      ",preferred,auto,1"
    ];
    general = {
      gaps_in = 0;
      gaps_out = 0;
      border_size = 1;
      # col.active_border = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      # col.inactive_border = "rgba(595959aa)";
      layout = "dwindle";
    };
    decoration = {
      rounding = 0;
      blur = {
        enabled = true;
        size = 3;
        passes = 1;
      };
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
      pseudotile = true;
      preserve_split = true;
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
    gestures = {
      workspace_swipe = true;
      workspace_swipe_min_fingers = true;
    };
    windowrulev2 = [
      "float,class:(copyq)"
      "move onscreen cursor,class:(copyq)"
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
      "$mod, X, togglesplit,"
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
