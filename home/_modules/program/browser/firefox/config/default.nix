# does NOT return a module, just an attrset

{ lib, pkgs-nur }:

let
  recursiveUpdates = lib.foldl lib.recursiveUpdate { };
in
{
  enable = true;

  policies = import ./policies.nix;

  profiles.default = {
    wavefox = {
      config = {
        "Tabs.Shape" = 8;
        "Tabs.Separators" = 2;
      };
    };

    search = import ./search.nix;
    settings = recursiveUpdates [
      (import ./settings.nix)
      (import ./toolbar.nix)
      {
        "extensions.autoDisableScopes" = 0; # auto enable 3rd party extensions
      }
    ];

    extensions.packages = with pkgs-nur.repos.rycee.firefox-addons; [
      bitwarden
      bypass-paywalls-clean
      darkreader
      ublock-origin-upstream
      vimium
    ];
  };
}
