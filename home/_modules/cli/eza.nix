{
  lib,
  ...
}:

{
  programs.eza = {
    enable = true;
    colors = "always";
    icons = "never";
    enableFishIntegration = false;
    extraOptions = [
      "--header"
      "--group-directories-first"
    ];
  };

  programs.fish = {
    shellAliases = {
      l = "eza";
      ls = "eza";
    };
    shellAbbrs = {
      ll = lib.mkForce "eza -l";
      la = "eza -lah";
      lt = "eza --tree";
    };
  };
}
