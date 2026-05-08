{
  modulePath,
  addonModule,
  ...
}:

{
  lib,
  config,
  ...
}:

let
  cfg = lib.attrByPath modulePath { } config;
in
{
  options = lib.setAttrByPath modulePath {
    webstore = {
      addons = lib.mkOption {
        type = with lib.types; listOf (submodule addonModule);
        default = [ ];
      };
      blockInstall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Block installation of addons through the webstore";
      };
    };
  };

  config = lib.setAttrByPath modulePath {
    policies.ExtensionSettings =
      (
        cfg.webstore.addons
        |> map (e: {
          ${e.id} = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${e.name}/latest.xpi";
            installation_mode = e.installation_mode;
            updates_disabled = true;
          };
        })
        |> lib.mergeAttrsList
      )
      // {
        "*".installation_mode = lib.mkIf cfg.webstore.blockInstall "blocked";
      };
  };
}
