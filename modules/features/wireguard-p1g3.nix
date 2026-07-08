{
  flake.nixosModules.wireguard-p1g3 =
    { ... }:
    {
      networking.wg-quick.interfaces = {
        home = {
          configFile = "/etc/wireguard/peer_p1g3/peer_p1g3.conf";
          autostart = false;
        };
      };
    };
}
