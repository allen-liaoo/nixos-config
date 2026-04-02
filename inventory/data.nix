# metadata of hosts and users
{ lib, config, alnLib, ... }:

let 
  users = {
    # me
    allenl = {
      name = "allenl";
      groups = [ "wheel" "input" ];
      can.deployNixConfig = true;
    };
    # vm user
    pig = {
      name = "pig";
      groups = [ "wheel" "input" ];
      can.deployNixConfig = true;
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
      users = with users; [ allenl ];
    };
    # laptop (TODO: switch to nixos)
    theseus = {
      name = "theseus";
      kind = "laptop";
      os = "generic-linux";
      system = "x86_64-linux";
      gpu = "amd";
      users = with users; [ allenl ];
    };
    # vm
    guinea = {
      name = "guinea";
      kind = "laptop";
      os = "nixos";
      system = "x86_64-linux";
      gpu = "amd";
      tags = [ "impermanent" ];
      users = with users; [ pig ];
    };
  };
  inherit users;
}
