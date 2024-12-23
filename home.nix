{ config, pkgs, ... }:

let
  myAliases = {
    ll = "ls -l";
  };

  cliphist-rofi-img = pkgs.writeShellScriptBin "cliphist-rofi-img" ''
    #!/usr/bin/env bash

    tmp_dir="/tmp/cliphist"
    rm -rf "$tmp_dir"

    if [[ -n "$1" ]]; then
        cliphist decode <<<"$1" | wl-copy
        exit
    fi

    mkdir -p "$tmp_dir"

    read -r -d ''' prog <<EOF
    /^[0-9]+\s<meta http-equiv=/ { next }
    match(\$0, /^([0-9]+)\s(\[\[\s)?binary.*(jpg|jpeg|png|bmp)/, grp) {
        system("echo " grp[1] "\\\\\t | cliphist decode >$tmp_dir/"grp[1]"."grp[3])
        print \$0"\0icon\x1f$tmp_dir/"grp[1]"."grp[3]
        next
    }
    1
    EOF
    cliphist list | gawk "$prog"
  '';

  patchDesktop = pkg: appName: from: to: lib.hiPrio (
    pkgs.runCommand "$patched-desktop-entry-for-${appName}" { } ''
      ${pkgs.coreutils}/bin/mkdir -p $out/share/applications
      ${pkgs.gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
    '');
  GPUOffloadApp = pkg: desktopName: patchDesktop pkg desktopName "^Exec=" "Exec=nvidia-offload ";
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
    pkgs.clang
    pkgs.rofi-wayland
    pkgs.rofimoji
    pkgs.cliphist
    pkgs.wl-clipboard
    pkgs.brightnessctl
    pkgs.brave
    pkgs.joplin-desktop
    pkgs.btop
    pkgs.seahorse
    pkgs.vscode.fhs
    pkgs.nixpkgs-fmt
    pkgs.uv
    pkgs.aoc-cli
    pkgs.xfce.thunar
    pkgs.xfce.thunar-volman
    pkgs.xfce.thunar-archive-plugin
    pkgs.xfce.thunar-media-tags-plugin
    (GPUOffloadApp pkgs.godot_4 "org.godotengine.Godot4")
  ];

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
    };

    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };

  programs.starship = {
    enable = true;
    settings = { };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    extraConfig = {
      credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
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

  services.swaync = {
    enable = true;
  };

  programs.kitty.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.variables = [ "--all" ];
  };

  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    "$terminal" = "kitty";
    "$fileManager" = "thunar";
    # debug.disable_logs = false;
    exec-once = [
      "wl-paste --type text --watch cliphist store"
      "wl-paste --type image --watch cliphist store"
    ];
    monitor = [
      "desc:BOE 0x086E,highres,0x0,1"
      "desc:Dell Inc. AW3423DWF BDC42S3,highres,auto-right,1"
      "desk:Microstep MSI MAG241CR 0x000001DA,highres,auto-right,1"
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
      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "borderangle, 1, 8, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
      ];
    };
    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };
    input = {
      kb_layout = "us,us,mk";
      kb_variant = "dvorak,,";
      kb_options = [
        "grp:win_space_toggle"
        "caps:escape"
      ];
      follow_mouse = 1;
      touchpad = {
        disable_while_typing = true;
        natural_scroll = true;
        tap-to-click = true;
        clickfinger_behavior = true;
        scroll_factor = 0.2;
      };
      force_no_accel = true;
      accel_profile = "flat";
      sensitivity = 0;
    };
    gestures = {
      workspace_swipe = true;
      workspace_swipe_min_fingers = true;
    };
    windowrulev2 = [
      "float,class:(copyq)"
      "move onscreen  cursor,class:(copyq)"
      "suppressevent maximize, class:.*"
    ];
    bind = [
      "$mod ALT, DELETE, exit,"
      "$mod, DELETE, exec, hyprlock"
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
      "$mod ALT, left, movecurrentworkspacetomonitor, l"
      "$mod ALT, right, movecurrentworkspacetomonitor, r"
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"
      "$mod, E, exec, $fileManager"
      "$mod, T, exec, $terminal"
      "$mod, SPACE, exec, rofi -show drun"
      "$mod, PERIOD, exec, rofimoji --action copy"
      "$mod, V, exec, cliphist list | rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons | cliphist decode | wl-copy"
      "$mod, grave, exec, swaync-client -t -sw"
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
    ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
