{ inputs, pkgs, lib, ... }@args: # for some unknown reason, need pkgs here

{
  imports = [
    inputs.glide.homeModules.default
    (import ./firefox/extendedFirefoxModule { 
      modulePath = [ "programs" "glide-browser" ];
    })
  ];

  programs.glide-browser = import ./firefox args;
    # disable toolbar
    # {
    #   profiles.default.settings."browser.uiCustomization.state" = {};
    # };
}
