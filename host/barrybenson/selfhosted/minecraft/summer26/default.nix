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
        white-list = false;
        enable-rcon = true;
        difficulty = 3;
      };

      package = pkgs.neoforgeServers.neoforge-1_21_1-21_1_228; # 229

      #whitelist = import ../players.nix;

      symlinks = {
        mods = pkgs.linkFarmFromDrvs "mods" (
          map pkgs.fetchurl (builtins.attrValues (import ./mods.nix))
        );
      };
    };
  };
}
