{ pkgs, inputs }:

let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };

  scriptDir = ../../../scripts;
  scriptFiles = builtins.attrNames (builtins.readDir scriptDir);

  scriptBins = map (
    name: pkgs.writeShellScriptBin name (builtins.readFile (scriptDir + "/${name}"))
  ) scriptFiles;
in
{
  home.packages = [
    pkgs.killall
    pkgs.clang
    pkgs.rofi
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
    pkgs-unstable.joplin-desktop
    pkgs.btop
    pkgs.seahorse

    pkgs.nixfmt
    pkgs.nixd
    pkgs-unstable.ty
    pkgs-unstable.uv
    pkgs.aoc-cli
    pkgs.thunar
    pkgs.thunar-volman
    pkgs.thunar-archive-plugin
    pkgs.thunar-media-tags-plugin
    pkgs.godotPackages_4_6.godot
    pkgs-unstable.vesktop
    pkgs.helio-workstation
    pkgs.pre-commit
    pkgs.audacity
    pkgs.shotcut
    pkgs.vlc
    pkgs.unzip
    pkgs.kdePackages.okular
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
    pkgs.jellyfin-media-player
    pkgs.zip
    pkgs.tealdeer
    pkgs.s-tui
    pkgs.stress-ng
    pkgs.http-server
    pkgs.prismlauncher
    pkgs.nodejs
    pkgs.steam-run
    (inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace packages/script/src/index.ts \
          --replace-fail \
            'if (!semver.satisfies(process.versions.bun, expectedBunVersionRange)) {' \
            'if (false && !semver.satisfies(process.versions.bun, expectedBunVersionRange)) {'
      '';
    }))
    inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ]
  ++ scriptBins;
}
