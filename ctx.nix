{
  lib,
  inventory,
  hostName,
  userName ? "",
}:

rec {
  host = inventory.hosts.${hostName};
  user = lib.findFirst (u: u.name == userName) null host.users; # use host.users, not inventory.users, since the former has computed info
}
