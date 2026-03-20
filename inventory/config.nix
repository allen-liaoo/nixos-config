# metadata of hosts and users
{ lib, config, ... }:

{
  hosts = {
    # vm
    guinea = {
      name = "guinea";
      system = "x86_64-linux";
      kind = "server";
      users = with config.users; [ pig ];
    };
  };

  users = {
    # vm user
    pig = {
      name = "pig";
      can.deploy_nix_config = true;
    };
  };
}
