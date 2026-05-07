# does NOT return a module, just an attrset

{ lib, pkgs, pkgs-nur, ... }: # same args as home modules

let 
  extensions = [
    {
      name = "darkreader";
      id = "addon@darkreader.org";
    }
    {
      name = "ublock-origin";
      id = "uBlock0@raymondhill.net";
    }
    {
      name = "vimium-ff";
      id = "{d7742d87-e61d-4b78-b8a1-b469842139fa}";
    }
    {
      name = "bitwarden-password-manager";
      id = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
    }
  ];
  recursiveUpdates = lib.foldl lib.recursiveUpdate {};
in
{
  enable = true;

  webstoreExtensions = extensions;
  wavefox = {
    enable = true;
    installForProfiles = [ "default" ];
    prefs = {
      "Tabs.Shape" = 8;
      "Tabs.Separators" = 2;
    };
  };
  pywalfox.enable = true;

  policies = import ./policies.nix;

  profiles.default = {
    search = import ./search.nix pkgs;
    settings = recursiveUpdates [
      (import ./settings.nix)
      (import ./toolbar.nix)
      {
        "extensions.autoDisableScopes" = 0; # auto enable 3rd party extensions
      }
    ];

    extensions.packages = [
      pkgs-nur.repos.rycee.firefox-addons.bypass-paywalls-clean # magnolia@12.34
    ];
  };
}
