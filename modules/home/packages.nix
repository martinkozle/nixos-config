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
