{
  lib,
  ctx,
  ...
}:

lib.mkIf ctx.host.is.laptop {
  # enable CUPS
  services.printing = {
    enable = true;
    browsing = true;
  };

  # automatic printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
