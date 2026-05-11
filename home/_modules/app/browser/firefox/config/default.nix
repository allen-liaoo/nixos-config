{ modulePath, profile }@args:

{
  lib,
  pkgs-nur,
  ...
}:

{
  imports = [
    (import ./policies.nix args)
    (import ./search.nix args)
    (import ./settings.nix args)
    (import ./toolbar.nix args)
  ];
}
// lib.setAttrByPath modulePath {
  enable = true;

  profiles.${profile} = {
    settings = {
      "extensions.autoDisableScopes" = 0; # auto enable 3rd party extensions
    };

    wavefox = {
      config = {
        "Tabs.Shape" = 8;
        "Tabs.Separators" = 2;
      };
    };

    extensions.packages = with pkgs-nur.repos.rycee.firefox-addons; [
      bitwarden
      bypass-paywalls-clean
      darkreader
      ublock-origin-upstream
      vimium
    ];
  };
}
