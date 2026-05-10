{
  programs.lazygit = {
    enable = true;
    settings = {
      tabWidth = 2;
    };
  };

  programs.fish.shellAbbrs = {
    lg = "lazygit";
  };
}
