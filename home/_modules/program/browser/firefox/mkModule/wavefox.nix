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
  wavefoxModule = { config, ... }: {
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
      extraConfig = config.wavefox.config
        |> lib.mapAttrsToList (n: v: ''user_pref("WaveFox.${n}", ${toString v});'')
        |> lib.concatStrings;
    };
  };
in
{
  options = lib.setAttrByPath modulePath {
    profiles = lib.mkOption { # extensible option
      type = with lib.types; attrsOf (submodule wavefoxModule);
    };
  };

  config = {
    home.file = cfg.profiles
      |> lib.filterAttrs (_: v: v.wavefox.enable)
      |> lib.mapAttrsToList (n: v: "${cfg.profilesPath}/${n}/chrome")
      |> (l: lib.genAttrs l (p: {
        source = inputs.wavefox.outPath + "/chrome";
      }));
  };

  # TODO: add import to wavefox instead of writing chrome dir
  # TODO: package wavefox
}
