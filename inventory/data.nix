# metadata of hosts and users
{ lib, config, alnLib, ... }:

let 
  users = {
    # me (full privileges)
    allenl = {
      name = "allenl";
    };
    # me on servers (i.e. restricted no ssh priv keys)
    al = {
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
        (al // {
          groups = [ "wheel" "input" ];
          can.deployNixConfig = true;
        })
      ];
    };
    # laptop
    theseus = {
      name = "theseus";
      kind = "laptop";
      os = "nixos";
      system = "x86_64-linux";
      gpu = "amd";
      users = with users; [
        (allenl // {
          groups = [ "wheel" "input" ];
          can.deployNixConfig = true;
        })
      ];
    };
    # vm
    guinea = {
      name = "guinea";
      kind = "laptop";
      os = "nixos";
      system = "x86_64-linux";
      gpu = "amd";
      tags = [];
      users = with users; [
        (pig // {
          groups = [ "wheel" "input" ];
          can.deployNixConfig = true;
        })
      ];
    };
  };
  inherit users;
}
