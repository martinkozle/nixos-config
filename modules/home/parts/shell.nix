{ pkgs, homeDirectory, ... }:

let
  myAliases = {
    ll = "ls -l";
  };
in
{
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
      path = "${homeDirectory}/.local/share/zsh/zsh_history";
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
