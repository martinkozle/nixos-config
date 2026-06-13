{
  flake.nixosModules.networking =
    { ... }:
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
    };
}
