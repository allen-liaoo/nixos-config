# metadata of hosts and users
{ lib, config, alnLib, ... }:

let 
  users = {
    # me
    allenl = {
      name = "allenl";
      tags = [ "sudoer" ];
      can.deployNixConfig = true;
    };
    # vm user
    pig = {
      name = "pig";
      tags = [ "sudoer" ];
      can.deployNixConfig = true;
    };
  };
in
{
  hosts = {
    # homeserver
    barrybenson = {
      name = "barrybenson";
      system = "x86_64-linux";
      kind = "server";
      tags = [ "impermanent" ];
      users = with users; [ allenl ];
    };
    # vm
    guinea = {
      name = "guinea";
      system = "x86_64-linux";
      kind = "server";
      tags = [ "impermanent" ];
      users = with users; [ pig ];
    };
  };
  inherit users;
}
