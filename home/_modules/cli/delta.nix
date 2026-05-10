{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      hyperlinks = true;
    };
  };

  programs.fish.shellAbbrs = {
    diff = "delta";
  };
}
