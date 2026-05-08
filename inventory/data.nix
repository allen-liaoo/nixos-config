# metadata of hosts and users
{
  lib,
  config,
  alnLib,
  ...
}:

let
  users = {
    allenl = {
      # full privileges
      name = "allenl";
      data = {
        ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPevSDBLs3jQWYE8sq2Dx6S2qQ4VzpKn5RvS1zXkGfiW wcliaw610@gmail.com";
      };
    };
    al = {
      # restricted
      name = "al";
    };
    # vm user
    pig = {
      name = "pig";
    };
  };
in
{
  hosts = {
    # homeserver
    barrybenson = {
      name = "barrybenson";
      kind = "server";
      os = "nixos";
      system = "x86_64-linux";
      gpu = "amd";
      tags = [ "impermanent" ];
      users = with users; [
        (
          al
          // {
            groups = [
              "wheel"
              "input"
            ];
            can.deployNixConfig = true;
          }
        )
      ];
      data = {
        wg_ip = "10.0.0.2";
        wg_pubkey = "g5YbSa4WFbDcnssaKGitMyN62ybeGGE/Mi3QDCkA5GA=";
      };
    };
    # laptop
    theseus = {
      name = "theseus";
      kind = "laptop";
      os = "nixos";
      system = "x86_64-linux";
      gpu = "amd";
      tags = [ "gui" ];
      users = with users; [
        (
          allenl
          // {
            groups = [
              "wheel"
              "input"
            ];
            can.deployNixConfig = true;
          }
        )
      ];
      data = {
        wg_ip = "10.0.10.1";
        wg_pubkey = "UKasTBMjRPnxeyI0xHPbYGM6JuqW6+7fZUDOF5Fjslw=";
      };
    };
    # vps (not on nixos and not managed by )
    ionobro = {
      name = "ionobro";
      kind = "server";
      os = "generic-linux";
      system = "x86_64-linux";
      tags = [ "impermanent" ];
      data = {
        ip = "74.208.158.11";
        wg_port = "51820";
        wg_ip = "10.0.0.1";
        wg_pubkey = "CQvf4nOExaVkaiWpsxx0OctRU4N51xRYdKUoKteegQk=";
      };
    };
    # vm
    guinea = {
      name = "guinea";
      kind = "laptop";
      os = "nixos";
      system = "x86_64-linux";
      gpu = "amd";
      tags = [ "gui" ];
      users = with users; [
        (
          pig
          // {
            groups = [
              "wheel"
              "input"
            ];
            can.deployNixConfig = true;
          }
        )
      ];
    };
  };
  inherit users;
}
