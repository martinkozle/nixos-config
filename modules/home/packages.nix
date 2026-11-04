{ inputs, ... }:
{
  flake.homeModules.packages =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;

      scriptDir = ../../scripts;
      scriptFiles = builtins.attrNames (builtins.readDir scriptDir);

      scriptBins = map (
        name: pkgs.writeShellScriptBin name (builtins.readFile (scriptDir + "/${name}"))
      ) scriptFiles;
    in
    {
      home.packages = [
        pkgs.killall
        pkgs.clang
        pkgs.rofimoji
        pkgs.hyprpicker
        pkgs.brightnessctl
        pkgs.playerctl
        # wl-copy/wl-paste: Claude Code shells out to wl-paste to read pasted images
        pkgs.wl-clipboard
        # rec: Claude Code's /voice records the microphone through SoX
        pkgs.sox
        pkgs.unstable.joplin-desktop
        pkgs.btop

        # CLI tooling
        pkgs.ripgrep
        pkgs.fd
        pkgs.jq
        pkgs.yq-go
        pkgs.tree
        pkgs.gh
        pkgs.shellcheck
        pkgs.shfmt

        # CLI video editing (for agents)
        # ffmpeg-full: drawtext, libass subtitles and the other filters plain ffmpeg leaves out
        pkgs.ffmpeg-full
        # melt: renders MLT XML timelines, the same project format Shotcut opens
        pkgs.mlt
        # auto-editor: cuts silence and dead air automatically
        pkgs.auto-editor
        # whisper-cli: local speech-to-text for subtitles (models are downloaded separately)
        pkgs.whisper-cpp
        pkgs.mediainfo
        pkgs.mkvtoolnix-cli
        pkgs.imagemagick
        pkgs.yt-dlp

        pkgs.nixfmt
        pkgs.nixd
        pkgs.unstable.ty
        pkgs.unstable.uv
        pkgs.aoc-cli
        pkgs.thunar
        pkgs.thunar-volman
        pkgs.thunar-archive-plugin
        pkgs.thunar-media-tags-plugin
        pkgs.godotPackages_4_6.godot
        pkgs.unstable.vesktop
        pkgs.helio-workstation
        pkgs.pre-commit
        pkgs.audacity
        pkgs.shotcut
        pkgs.vlc
        pkgs.unzip
        pkgs.kdePackages.okular
        pkgs.cargo
        pkgs.rustc
        pkgs.libreoffice-fresh
        pkgs.hunspell
        pkgs.hunspellDicts.en_US
        pkgs.teams-for-linux
        pkgs.signal-desktop
        pkgs.gnumake
        pkgs.cmake
        pkgs.jellyfin-media-player
        pkgs.zip
        pkgs.tealdeer
        pkgs.s-tui
        pkgs.stress-ng
        pkgs.http-server
        pkgs.prismlauncher
        pkgs.nodejs
        pkgs.steam-run
        inputs.herdr-nix.packages.${system}.default
      ]
      ++ scriptBins;
    };
}
