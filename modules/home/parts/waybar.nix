{ ... }:

{
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
}
