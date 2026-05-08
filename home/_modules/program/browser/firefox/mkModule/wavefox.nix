{
  modulePath,
  ...
}:

{
  lib,
  config,
  pkgs-aln,
  ...
}:

let
  cfg = lib.attrByPath modulePath { } config;
  wavefoxModule =
    { config, ... }:
    {
      options.wavefox = {
        enable = lib.mkEnableOption "wavefox";
        package = lib.mkPackageOption pkgs-aln "wavefox" {
          extraDescription = ''
            The "chrome" folder of wavefox must be the root of the derivation, and must contain "userChrome.css" and "userContent.css" files.
          '';
        };
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
            source = v.wavefox.package;
          };
        }
      );
  };
}
