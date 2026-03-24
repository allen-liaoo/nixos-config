{ lib, aln, config, ... }:

{
  networking.wg-quick.interfaces = {
    # TODO: Table routing management??
    wg_vps = {
      address = [ "10.0.0.2/24" ];
      privateKeyFile = config.sops.secrets.wg_privkey.path;
      peers = [
        #vps
        {
          publicKey = "CQvf4nOExaVkaiWpsxx0OctRU4N51xRYdKUoKteegQk=";
          endpoint = "74.208.158.11:51820";
          # set allowed ip to anything so any dst ip can be routed through tunnel
          # with Table = off, what is routed through is what is marked 51820
          #allowedIPs = [ "0.0.0.0/0" ];
          allowedIPs = [ "10.0.0.1/32" ];
        }
      ];
    };
  };

  sops.secrets.wg_privkey = {
    key = "wg_privkey";
  };
}
