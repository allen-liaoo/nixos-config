{
  modulePath,
  extensionModule,
  ...
}:

{
  lib,
  config,
  ...
}:

let
  cfg = lib.attrByPath modulePath {} config;
in
{
  options = lib.setAttrByPath modulePath {
    webstoreExtensions = lib.mkOption {
      type = with lib.types; listOf (submodule extensionModule);
      default = [ ];
    };
  };

  config = lib.setAttrByPath modulePath {
    # installs extensions from the mozilla store
    policies.ExtensionSettings = 
      cfg.webstoreExtensions
      |> map (e:{
          ${e.id} = {
            install_url       = "https://addons.mozilla.org/firefox/downloads/latest/${e.name}/latest.xpi";
            installation_mode = "force_installed";
            updates_disabled  = true;
          };
        })
      |> lib.mergeAttrsList;
  };
}
