# Herdr desktop app + herdr-core, from the official release tarballs.
# Versions and hashes are pinned in herdr.json; bump them with `herdr-update`.
#
# Both programs update themselves on other platforms. Here they can't (the
# store is read-only), so:
# - herdr-core sees it lives in /nix/store and tells you to update via Nix.
# - herdr-app only self-updates when herdr-app.svg sits beside its binary, so
#   the binary goes in libexec/ without it and the icon goes to share/icons.
{
  flake.homeModules.herdr =
    { pkgs, ... }:
    let
      pins = builtins.fromJSON (builtins.readFile ./herdr.json);

      herdr-core = pkgs.stdenvNoCC.mkDerivation {
        pname = "herdr-core";
        inherit (pins.core) version;
        src = pkgs.fetchurl { inherit (pins.core) url sha256; };
        sourceRoot = ".";
        # Statically linked: nothing to patch.
        installPhase = ''
          install -Dm755 herdr-core $out/bin/herdr-core
          ln -s herdr-core $out/bin/hc
        '';
      };

      herdr-app = pkgs.stdenv.mkDerivation {
        pname = "herdr-app";
        inherit (pins.app) version;
        src = pkgs.fetchurl { inherit (pins.app) url sha256; };

        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [
          pkgs.stdenv.cc.cc.lib
          pkgs.libxcb
          pkgs.libxkbcommon
        ];
        # dlopen()ed at runtime (GPUI): added to the binary's RUNPATH.
        runtimeDependencies = [
          pkgs.vulkan-loader
          pkgs.wayland
          pkgs.libGL
          pkgs.libxkbcommon
        ];

        installPhase = ''
          install -Dm755 herdr-app $out/libexec/herdr-app/herdr-app
          mkdir -p $out/bin
          ln -s $out/libexec/herdr-app/herdr-app $out/bin/herdr-app
          install -Dm644 herdr-app.svg $out/share/icons/hicolor/scalable/apps/herdr-app.svg
        '';
      };
    in
    {
      home.packages = [
        herdr-core
        herdr-app
        (pkgs.makeDesktopItem {
          name = "herdr-app";
          desktopName = "Herdr";
          comment = "Terminals and coding agents that keep running";
          exec = "herdr-app";
          icon = "herdr-app";
          categories = [ "Development" ];
          startupWMClass = "herdr-app";
        })
      ];
    };
}
