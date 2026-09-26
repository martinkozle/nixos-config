# AI coding tools from numtide/llm-agents.nix, served prebuilt from
# cache.numtide.com. Without the cache codex is a ~1h / ~12 GiB Rust build that
# OOMs the 16 GB t14s. Update with `ai-update` (scripts/ai-update), which rolls
# the lock back if anything would compile locally.
{ inputs, config, ... }:
{
  flake.homeModules.ai-tools =
    { pkgs, ... }:
    let
      llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home.packages = [
        llm-agents.opencode
        llm-agents.codex
        llm-agents.chatgpt
        llm-agents.claude-code
        llm-agents.claude-desktop
        # nixos MCP server for Claude Code / opencode / codex. Installed here rather than
        # `nix run github:...` in the agent configs: that builds locally and exceeds the
        # 30s MCP connect timeout.
        pkgs.mcp-nixos
      ];
    };

  flake.nixosModules.ai-tools = {
    # Set here, not in flake `nixConfig`: martin is not in trusted-users, so the
    # daemon ignores flake-level substituters. Only hits while the llm-agents
    # input does not `follows` our nixpkgs.
    nix.settings = {
      substituters = [ "https://cache.numtide.com" ];
      trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
    };

    home-manager.sharedModules = [ config.flake.homeModules.ai-tools ];
  };
}
