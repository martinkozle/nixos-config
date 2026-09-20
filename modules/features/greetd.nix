{ inputs, ... }:
{
  flake.nixosModules.greetd =
    { pkgs, ... }:
    let
      hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      startHyprland = "${hyprland}/bin/start-hyprland";

      # A single, clean Hyprland session entry. We hand tuigreet this explicit
      # dir instead of relying on $XDG_DATA_DIRS discovery: on NixOS the
      # hyprland package ships BOTH hyprland.desktop and a stale
      # hyprland-uwsm.desktop, and both leak into XDG_DATA_DIRS (via the
      # display-manager "desktops" runCommand and the profile), so autodiscovery
      # shows 2x "Hyprland" + 2x "Hyprland (uwsm)".
      hyprlandSession = pkgs.writeTextDir "wayland-sessions/hyprland.desktop" ''
        [Desktop Entry]
        Name=Hyprland
        Comment=An intelligent dynamic tiling Wayland compositor
        Exec=${startHyprland}
        Type=Application
        DesktopNames=Hyprland
        Keywords=tiling;wayland;compositor;
      '';
    in
    {
      _module.args.inputs = inputs;

      # tuigreet must be on the system PATH for greetd to exec it.
      # hyprlandSession is listed only so its store path is built into the
      # closure (the greetd command references it by absolute path); it sits at
      # the package root, not under a linked share/ path, so it never reaches
      # the profile's XDG session dirs.
      environment.systemPackages = [
        pkgs.tuigreet
        hyprlandSession
      ];

      services.greetd = {
        enable = true;
        # tuigreet is a text/console greeter; this tunes the systemd unit so
        # boot messages don't clobber the TUI on tty1.
        useTextGreeter = true;
        settings = {
          # The greeter itself runs as the `greeter` system user (module default).
          # --sessions points at our single-file dir, overriding XDG discovery.
          default_session.command = "tuigreet --time --remember --sessions ${hyprlandSession}/wayland-sessions";
        };
      };
    };
}
