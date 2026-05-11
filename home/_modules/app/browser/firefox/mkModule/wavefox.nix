{
  modulePath,
  ...
}:

{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = lib.attrByPath modulePath { } config;
  wavefox = pkgs.fetchFromGitHub {
    owner = "QNetITQ";
    repo = "WaveFox";
    rev = "v1.9.150";
    hash = "sha256-cFrKG9VGDda9sFcAu/6zvpsd82TUOWTTEZVoaCLt1gg=";
    sparseCheckout = [
      "/chrome"
    ];
  };
  wavefoxModule =
    { config, ... }:
    {
      options.wavefox = {
        enable = lib.mkEnableOption "wavefox";
        config = lib.mkOption {
          type = with lib.types; attrsOf (either str int);
          default = { };
          description = ''
            Config attrset for wavefox, i.e. user_pref("WaveFox.{attrName}", {attrValue});
          '';
        };
      };
      config = lib.mkIf config.wavefox.enable {
        extraConfig =
          config.wavefox.config
          |> lib.mapAttrsToList (n: v: ''user_pref("WaveFox.${n}", ${toString v});'')
          |> lib.concatStrings;
        userChrome = lib.mkIf config.wavefox.enable ''
          @import "wavefox/userChrome.css"
        '';
        userContent = lib.mkIf config.wavefox.enable ''
          @import "wavefox/userContent.css"
        '';
      };
    };
in
{
  options = lib.setAttrByPath modulePath {
    profiles = lib.mkOption {
      # extensible option
      type = with lib.types; attrsOf (submodule wavefoxModule);
    };
  };

  config = {
    home.file =
      cfg.profiles
      |> lib.filterAttrs (_: v: v.wavefox.enable)
      |> lib.mapAttrs' (
        n: v: {
          name = "${cfg.profilesPath}/${n}/chrome/wavefox";
          value = {
            source = "${wavefox}/chrome";
          };
        }
      );
  };
}
