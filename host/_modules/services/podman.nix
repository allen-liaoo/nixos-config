{ ... }:

{
  users.users.containers = {
    isSystemUser = true;
    group = "containers";
  };
  users.groups.containers = {};

  # container subuid/subgid mapping
  # have to set subuid and subgid directly in file as userborn does not support subuid/asubgid options (see users.nix)
  # https://github.com/nikstur/userborn/issues/7
  environment.etc."subuid" = {
    text = "containers:2147483647:2147483648\n";
    mode = "0644";
  };
  environment.etc."subgid" = {
    text = "containers:2147483647:2147483648\n";
    mode = "0644";
  };

  # need to set ip forwarding for containers to send/receive packets
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # quadlet-nix package
  virtualisation.quadlet = {
    enable = true;
    autoEscape = true;
    autoUpdate = {
      enable = true;
      calendar = "Mon *-*-* 00:00:00"; # every week
    };
  };
}
