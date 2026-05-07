{
  modulePath,
  extensionModule,
  ...
}:

{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = lib.attrByPath modulePath {} config;
  installThruWebstore = lib.isDerivation cfg.pywalfox.extension;
in
{
  options = lib.setAttrByPath modulePath {
    pywalfox = {
      enable = lib.mkEnableOption "pywalfox";
      package = lib.mkPackageOption pkgs "pywalfox-native" {
        extraDescription = "pywalfix (as native messaging host) to install, will be installed to home PATH";
      };
      extension = lib.mkOption {
        type = with lib.types; either (submodule extensionModule) package;
        description = "pywalfox extension to install";
        default = {
          id = "pywalfox@frewacom.org";
          name = "pywalfox";
        };
      };
      installForProfiles = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
      };
    };
  };

  config = {
    home = {
      # native messaging host
      packages = [ cfg.pywalfox.package ];
      activation = {
        pywalfoxInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''
          ${lib.getExe cfg.pywalfox.package} install > /dev/null 2>&1
        '';
      };
      # setup DMS managed matugen theme
      file = {
        ".cache/wal/colors.json".source = config.lib.file.mkOutOfStoreSymlink (config.home.homeDirectory + "/.cache/wal/dank-pywalfox.json");
      };
    };

  } //

  # install extension thru webstore
  lib.setAttrByPath modulePath {
    webstoreExtensions = lib.optionals installThruWebstore [
      cfg.pywalfox.extension
    ];
    # or install extension as package
    profiles = lib.optionalAttrs (!installThruWebstore) 
      (lib.genAttrs cfg.pywalfox.installForProfiles (p: {
          extensions.packages = [ cfg.pywalfox.extension ];
        }));
  };

}
