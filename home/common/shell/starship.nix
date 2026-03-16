{ lib, customLib, config, ... }:
{
  programs.starship = {
    enable = true;
    # ONLY WOKKS IF THIS REPO IS IN USER HOME!!
    configPath = builtins.toString ./starship.toml; #(customLib.relToBase config.home.homeDirectory ./starship.toml);
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableInteractive = true; # only when interactive
  };
}
