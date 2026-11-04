{
  flake.nixosModules.docker = {
    virtualisation.docker = {
      enable = true;
      # Start dockerd on first use (socket activation) instead of at boot.
      # Containers with a restart policy only come back once docker is used.
      enableOnBoot = false;
      # A per-user daemon, so agents can use Docker without the root-equivalent docker group.
      # setSocketVariable points DOCKER_HOST at it in user sessions.
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };
}
