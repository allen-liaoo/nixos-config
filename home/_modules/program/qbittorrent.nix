{
  pkgs,
  config,
  alnLib,
  ...
}:

{
  home.packages = with pkgs; [
    qbittorrent
  ];

  xdg.dataFile."qBittorrent/nova3/engines/jackett.json".source =
    config.lib.file.mkOutOfStoreSymlink config.sops.templates.qbit_jackett_settings.path;

  sops.templates.qbit_jackett_settings.content = ''
    {
      "api_key": "${config.sops.placeholder.jackett_api_key}",
      "url": "https://jackett.allenl.me:443",
      "tracker_first": false,
      "thread_count": 20
    }
  '';

  sops.secrets.jackett_api_key = {
    sopsFile = alnLib.relToRoot "secrets/user/allenl/common.yaml";
    key = "jackett_api_key";
  };
}
