{ inputs, pkgs, lib, ... }@args: # for some unknown reason, need pkgs here

{
  imports = [
    inputs.glide.homeModules.default
  ];

  programs.glide-browser = { enable = true; };
    # (import ./firefox args) //
    # # disable toolbar
    # {
    #   profiles.default.settings."browser.uiCustomization.state" = {};
    # };
}
