{ lib, config, pkgs, inputs, ... }@args:

{
  programs.firefox = import ./firefox args;
  home.file.".mozilla/firefox/default/chrome".source = inputs.wavefox.outPath + "/chrome";

  stylix.targets.firefox = lib.mkIf (config.stylix.enable) {
    colorTheme.enable = true;
    profileNames = [ "default" ];
  };
}
