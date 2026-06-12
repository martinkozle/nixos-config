{
  flake.nixosModules.networking =
    { config, pkgs, ... }:
    {
      networking.networkmanager.enable = true;

      networking.firewall = {
        allowedUDPPorts = [
          12344
          12345
          12346
          51820
        ];
      };

      networking.wg-quick.interfaces = {
        home = {
          configFile = "/etc/wireguard/peer_p1g3/peer_p1g3.conf";
          autostart = false;
        };
      };
    };
}
