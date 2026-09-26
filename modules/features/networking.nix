{
  flake.nixosModules.networking =
    { ... }:
    {
      networking.networkmanager.enable = true;

      services.avahi = {
        enable = true;
        publish.enable = true;
      };

      networking.firewall = {
        allowedUDPPorts = [
          # Global Game Jam 2026 game server
          12344
          12345
          12346
          # WireGuard (ListenPort in /etc/wireguard/peer_*.conf)
          51820
        ];
      };
    };
}
