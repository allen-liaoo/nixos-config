{
  inputs,
  lib,
  ...
}:

let
  modulePath = [
    "programs"
    "glide-browser"
  ];
in
{
  imports = [
    inputs.glide.homeModules.default
    (import ./firefox/mkModule { inherit modulePath; })
    (import ./firefox/config {
      inherit modulePath;
      profile = "default";
    })
  ];

  programs.glide-browser = {
    pywalfox.enable = false;
    # disable toolbar
    profiles.default.settings."browser.uiCustomization.state" = { };
  };
}
