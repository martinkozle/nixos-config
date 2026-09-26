{ inputs, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    {
      formatter = pkgs.nixfmt;

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
