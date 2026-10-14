{
  flake.nixosModules.audio =
    { ... }:
    {
      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;

        # WebRTC auto gain control (Chromium/Brave/Electron, Firefox) lowers the
        # mic's source volume when you talk loudly and never raises it again.
        # Block source-volume changes from every pulse client except mixers.
        # Noctalia and wpctl use native PipeWire, so they are unaffected.
        extraConfig.pipewire-pulse."10-block-source-volume" = {
          "pulse.rules" = [
            {
              matches = [ { "application.process.binary" = "!~^\\.?(pavucontrol|pwvucontrol).*"; } ];
              actions.quirks = [ "block-source-volume" ];
            }
          ];
        };
      };
    };
}
