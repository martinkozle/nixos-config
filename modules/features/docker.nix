{
  flake.nixosModules.docker = {
    virtualisation.docker = {
      enable = true;
      # Start dockerd on first use (socket activation) instead of at boot.
      # Containers with a restart policy only come back once docker is used.
      enableOnBoot = false;
    };
  };
}
