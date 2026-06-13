{
  flake.nixosModules.wireguard-t14s =
    { ... }:
    {
      networking.wg-quick.interfaces = {
        home = {
          configFile = "/etc/wireguard/peer_t14s/peer_t14s.conf";
          autostart = false;
        };
      };
    };
}
