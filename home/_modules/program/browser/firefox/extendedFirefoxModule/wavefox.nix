{
  modulePath,
  ...
}:

{
  lib,
  config,
  inputs,
  ...
}:

let
  cfg = lib.attrByPath modulePath {} config;
in
{
  options = lib.setAttrByPath modulePath {
    wavefox = {
      enable = lib.mkEnableOption "wavefox";
      installForProfiles = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
      };
      prefs = lib.mkOption {
        type = with lib.types; attrsOf (either str int);
        default = { };
        description = ''
          Config for wavefox, i.e. user_pref("WaveFox.{attrName}", {attrValue});
        '';
      };
    };
  };

  config = {
    home.file = lib.mkIf (cfg.wavefox.enable) 
      (cfg.wavefox.installForProfiles
      |> lib.map (p: "${cfg.profilesPath}/${p}/chrome")
      |> (l: lib.genAttrs l (p: {
          source = inputs.wavefox.outPath + "/chrome";
        })));
  } //

  lib.setAttrByPath modulePath {
    profiles = lib.optionalAttrs cfg.wavefox.enable 
      (lib.genAttrs cfg.pywalfox.installForProfiles (p: {
          extraConfig = cfg.wavefox.prefs;
        }));
  };

  # TODO: add import to wavefox instead of writing chrome dir
  # TODO: package wavefox
}
