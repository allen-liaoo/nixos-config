# extends HM's mkFirefoxModule, meant to be merged with a FirefoxModule
# https://github.com/nix-community/home-manager/blob/master/modules/programs/firefox/mkFirefoxModule.nix

# takes extendArgs to instantiate the extended module (distinct from args that are instantiated by module system)
{
  modulePath,
}@extendArgs:

{
  lib,
  ...
}:

let
  addonModule = {
    options = {
      id = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = ''
          name@domain or {uuid}.
                    To find addon ids/uuids, go to about:debugging#/runtime/this-firefox.
        '';
        example = "addon@darkreader.org or {c6ca2584-3216-46b8-b929-02743f1d8726}";
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = ''
          Name of addon in mozilla store.
                    To find the name, check extension url in webstore, which should be something like https://addons.mozilla.org/en-US/firefox/addon/NAME/.
        '';
        example = "darkreader";
      };
      installation_mode = lib.mkOption {
        type = lib.types.enum [
          "allowed"
          "blocked"
          "force_installed"
          "normal_installed"
        ];
        default = "force_installed";
      };
    };
  };
  newExtendArgs = extendArgs // {
    inherit addonModule;
  };
in
{
  imports = [
    (import ./webstore.nix newExtendArgs)
    (import ./pywalfox.nix newExtendArgs)
    (import ./wavefox.nix newExtendArgs)
  ];
}
