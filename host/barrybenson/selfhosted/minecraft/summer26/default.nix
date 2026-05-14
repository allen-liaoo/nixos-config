{
  pkgs,
  ...
}:

{
  services.minecraft-servers = {
    servers.summer26 = {
      enable = true;
      autoStart = true;
      enableReload = true;
      serverProperties = {
        server-port = 25565;
        white-list = true;
        enable-rcon = true;
        difficulty = 3;
      };

      package = pkgs.neoforgeServers.neoforge-1_21_1-21_1_229;

      whitelist = import ../players.nix;

      symlinks = {
        mods = pkgs.linkFarmDromDrvs "mods" (
          builtins.attrValues (import ./mods.nix pkgs.fetchurl)
        );
      };
    };
  };
}

/*
  {
    "url": "{url}",
    "version": "{version}",
    "filename: "{filename}"
  },
*/
