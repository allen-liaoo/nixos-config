{
  modulePath,
  addonModule,
  ...
}:

{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = lib.attrByPath modulePath { } config;
  vendor =
    if cfg ? vendorPath && cfg.vendorPath != null then
      cfg.vendorPath
    else
      config.home.homeDirectory + "/.mozilla"; # only on linux and for firefox
  installThruWebstore = !(lib.isDerivation cfg.pywalfox.extension);
in
{
  options = lib.setAttrByPath modulePath {
    pywalfox = {
      enable = lib.mkEnableOption "pywalfox native messaging host";
      package = lib.mkPackageOption pkgs "pywalfox-native" {
        extraDescription = "native messaging host package (requires >= v2.9.0)";
      };
      extension = lib.mkOption {
        type = with lib.types; either (submodule addonModule) package;
        description = "pywalfox extension to install";
        default = {
          id = "pywalfox@frewacom.org";
          name = "pywalfox";
        };
      };
      installForProfiles = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = "Install pywalfox extension for following profiles; can only achieve per-profile install if extension is a package";
      };
    };
  };

  config = lib.mkIf cfg.pywalfox.enable (
    {
      home.activation = {
        pywalfoxInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${lib.getExe cfg.pywalfox.package} install \
            --manifest-path ${vendor}/native-messaging-hosts \
            --profile-path  ${cfg.profilesPath} \
            > /dev/null 2>&1
          # pywalfox does not yet support following system preferred theme: https://github.com/Frewacom/pywalfox/issues/149
          # in the meantime, set dark theme
          ${lib.getExe cfg.pywalfox.package} dark > /dev/null 2>&1
        '';
      };

    }
    //
      # install extension thru webstore
      lib.setAttrByPath modulePath {
        webstore.addons = lib.mkIf installThruWebstore [
          cfg.pywalfox.extension
        ];
        # or install extension as package
        profiles = lib.mkIf (!installThruWebstore) (
          lib.genAttrs cfg.pywalfox.installForProfiles (p: {
            extensions.packages = [ cfg.pywalfox.extension ];
          })
        );
      }
  );
}
