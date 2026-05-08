{ inputs, lib, ... }@args: # for some unknown reason, need pkgs here

{
  imports = [
    inputs.glide.homeModules.default
    (import ./firefox/mkModule { 
      modulePath = [ "programs" "glide-browser" ];
    })
  ];

  programs.glide-browser = lib.mkMerge [
    (import ./firefox/config { inherit (args) lib pkgs-nur; })
    {
      pywalfox.enable = false;
      # disable toolbar
      profiles.default.settings."browser.uiCustomization.state" = {};
    }
  ];
}
