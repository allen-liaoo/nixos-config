# extends HM's mkFirefoxModule, meant to be merged with a FirefoxModule
# https://github.com/nix-community/home-manager/blob/master/modules/programs/firefox/mkFirefoxModule.nix

# takes extendArgs to instantiate the extended module (distinct from args that are instantiated by module system)
{
  modulePath
}@extendArgs:

{
  lib,
  pkgs,
  ...
}:

let 
  extensionModule = {
    options = {
      id = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "name@dev or {uuid}. To find extension ids/uuids, go to about:debugging#/runtime/this-firefox.";
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Name in mozilla store. To find extension name, check extension url in webstore, which should be something like https://addons.mozilla.org/en-US/firefox/addon/NAME/.";
      };
    };
  };
  newExtendArgs = extendArgs // { inherit extensionModule; };
in
{
  imports = [
    (import ./extensions.nix newExtendArgs)
    (import ./pywalfox.nix newExtendArgs)
    (import ./wavefox.nix newExtendArgs)
  ];
}
