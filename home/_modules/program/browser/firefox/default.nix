# thin wrapper around Home-Manager's mkFirefoxModule
# https://github.com/nix-community/home-manager/blob/master/modules/programs/firefox/mkFirefoxModule.nix
# All settings are under "default" profile
{ lib, config, pkgs, pkgs-nur, aln, ... }: # same args as home modules

let 
  extensions = import ./extensions_meta.nix;
  recursiveUpdates = lib.foldl lib.recursiveUpdate {};
in
{
  enable = true;
  policies = recursiveUpdates [
    (import ./policies.nix)
    {
      # installs extensions from the mozilla store
      ExtensionSettings = lib.mergeAttrsList (map (ext: 
        lib.optionalAttrs (ext ? name && ext.name != "") {
          ${ext.id} = {
            install_url       = "https://addons.mozilla.org/firefox/downloads/latest/${ext.name}/latest.xpi";
            installation_mode = "force_installed";
            updates_disabled  = true;
          };
        })
        extensions);
    }
  ];

  profiles.default = {
    search = import ./search.nix pkgs;
    settings = recursiveUpdates [
      (import ./settings.nix)
      (import ./toolbar.nix)
      {
        "extensions.autoDisableScopes" = 0; # auto enable 3rd party extensions
      }
    ];

    extensions = {
      force = true;
      # set extension settings
      settings = lib.mergeAttrsList (map (ext: 
        lib.optionalAttrs (ext ? settings && ext.settings != { }) {
          ${ext.id} = ext.settings;
        }) 
        extensions);
      # 3rd party extensions
      packages = with pkgs-nur.repos.rycee.firefox-addons; [
        bypass-paywalls-clean
      ];
    };

    # Wavegox needs to be installed separately (via home.file) 
    extraConfig = ''
      user_pref("WaveFox.Tabs.Shape", 8);
      user_pref("WaveFox.Tabs.Separators", 2);
    '';
  };
}
