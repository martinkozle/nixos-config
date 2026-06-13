{ pkgs, inputs }:

let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  programs.vscode = {
    enable = true;
    package = pkgs-unstable.vscode.fhs;
  };

  programs.lazyvim = {
    enable = true;

    installCoreDependencies = true;
    extras = {
      lang.nix.enable = true;
      lang.python = {
        enable = true;
        installDependencies = true;
        installRuntimeDependencies = false;
      };
    };
  };

  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "toml"
      "yaml"
      "rust"
      "python"
    ];
    userSettings = {
      theme = {
        mode = "dark";
        dark = "One Dark";
        light = "One Light";
      };
      hour_format = "hour24";
      vim_mode = true;
      base_keymap = "VSCode";
      languages = {
        Nix = {
          language_servers = [
            "nixd"
            "!nil"
          ];
        };
        Python = {
          language_servers = [
            "ty"
            "ruff"
            "!basedpyright"
          ];
        };
      };
    };
  };
}
