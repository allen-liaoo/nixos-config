{
  pkgs,
  ...
}:

{
  services.minecraft-servers = {
    servers.summer26 = {
      enable = true;
      autoStart = true;
      serverProperties = {
        server-port = 25565;
        white-list = true;
        enable-rcon = true;
        difficulty = 3;
      };

      package = pkgs.neoforgeServers.neoforge-1_21_1-21_1_229;

      symlinks = {
        mods = pkgs.linkFarmDromDrvs "mods" (
          builtins.attrValues {
            Aether-Villages = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/YhmgMVyu/versions/K5X5qMwG/aether-1.21.1-1.5.10-neoforge.jar";
              sha512 = "4b004daed6d09362646e204f068dee28e80523e705e862778036c492775672071ca9cc95f9574a842f34d2e058b46138c6154c6a2f251dcdad7a8803907dad46"; 
            };
          }
        );
      };

      files."white-list.txt" = {
        value = [
        ];
      };
    };
  };
}
