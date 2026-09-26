{
  flake.nixosModules.security = {
    # Reboot/poweroff from the session needs no extra rule: logind already
    # allows it for the active local session.
    security.polkit.enable = true;
  };
}
