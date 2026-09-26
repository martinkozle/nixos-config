{ inputs, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    {
      # nixfmt-tree: `nix fmt` with no arguments formats the whole repo
      # (plain nixfmt would wait on stdin).
      formatter = pkgs.nixfmt-tree;

      checks.pre-commit-check = inputs.git-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
        src = ../..;
        hooks = {
          nixfmt.enable = true;
        };
      };

      devShells.default =
        let
          inherit (self'.checks.pre-commit-check) shellHook enabledPackages;
        in
        pkgs.mkShell {
          inherit shellHook;
          buildInputs = enabledPackages;
        };
    };
}
