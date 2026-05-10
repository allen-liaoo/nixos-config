{
  config,
  ctx,
  ...
}:

{
  programs.home-manager.enable = true;

  services.home-manager = {
    # expire hm generations daily, for generations older than 7 days
    # but let nix.gc handle cleanup
    autoExpire = {
      enable = true;
      frequency = "daily";
      timestamp = "-7 days";   
      store.cleanup = false;
    };
  };

  home.username = ctx.user.name;
  home.homeDirectory = "/home/${ctx.user.name}";

  xdg = {
    enable = true;
    cacheHome = config.home.homeDirectory + "/.cache";
    configHome = config.home.homeDirectory + "/.config";
    dataHome = config.home.homeDirectory + "/.local/share";
    stateHome = config.home.homeDirectory + "/.local/state";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
}
