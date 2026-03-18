# metadata of hosts and users
{ lib, ... }:

let
  system = {
    x86_linux = "x86_64-linux";
  };
in rec
{
  hosts = {
    # vm
    guinea = {
      name = "guinea";
      system = system.x86_linux;
      users = with users; [ pig.name ];
    };
  };

  users = {
    # vm user
    pig = {
      name = "pig";
      primary = true;
    };
    };
  # Derived from meta
  hostNames = builtins.attrNames hosts;
  userNames = builtins.attrNames users;

  # All "user@host" pairs that need a homeConfiguration
  userHostPairs = lib.flatten (
    lib.mapAttrsToList (hostName: hostCfg:
      map (userName: { inherit userName hostName; }) hostCfg.users
    ) hosts
  );

  # Does host X have user Y?
  hostHasUser = hostName: userName:
    builtins.elem userName hosts.${hostName}.users;

  # Get all users metadata for a host as attrs
  usersForHost = hostName:
    lib.genAttrs hosts.${hostName}.users (u: users.${u});

  isNixOS = (hostName: hostName != "default");
}
