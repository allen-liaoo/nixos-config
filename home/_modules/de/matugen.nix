{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  mtgTemplate = path: inputs.matugen-themes.outPath + "/templates/" + path;
  template = { name, ... }: {
    options = {
      enable = lib.mkEnableOption name;
      content = lib.mkOption { type = lib.types.attrs; };
    };
  };
  dmsEnabled = config.programs.dank-material-shell.enable;
in
{
  options = {
    matugen = {
      templates = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule template);
        default = { };
      };
    };
  };

  config = {
    xdg.configFile."matugen/config.toml".source = (pkgs.formats.toml {}).generate "config.toml" {
      config = {};
      templates = (config.matugen.templates
        |> lib.filterAttrs (_: v: v.enable)
        |> lib.mapAttrs (_: v: v.content));
    };

    matugen.templates = {
      btop = {
        enable = config.programs.btop.enable;
        content = {
          input_path = mtgTemplate "btop.theme";
          output_path = "${config.xdg.configHome}/btop/themes/mutagen.theme";
          post_hook = "pkill -USR2 btop || true";
        };
      };

      vicinae = {
        enable = config.services.vicinae.enable;
        content = {
          input_path = inputs.vicinae.outPath + "/extra/matugen.toml";
          output_path = config.xdg.dataHome + "/vicinae/themes/matugen.toml";
          post_hook = "${lib.getExe config.services.vicinae.package} theme set matugen";
        };
      };

      yazi = {
        enable = config.programs.yazi.enable;
        content = {
          input_path = mtgTemplate "yazi-theme.toml";
          output_path = config.xdg.configHome + "/yazi/theme.toml";
        };
        # no support for live reloading yet
      };

      zellij = {
        enable = config.programs.zellij.enable;
        content = {
          input_path = mtgTemplate "zellij-theme.kdl.tera";
          output_path = config.xdg.configHome + "/zellij/themes/matugen.kdl";
          post_hook = "touch ${config.xdg.configHome}/zellij/config.kdl"; # live reload
        };
      };
    };

    programs.btop.settings.color_theme = "matugen";

    services.vicinae.settings.theme = {
      dark.name = "matugen";
      light.name = "matugen";
    };

    # DMS managed matugen themes
    # https://danklinux.com/docs/dankmaterialshell/application-themes
    programs.dank-material-shell.settings = lib.mkIf dmsEnabled {
      runUserMatugenTemplates = true;
      runDmsMatugenTemplates = true;
      matugenTemplateAlacritty = true;
      matugenTemplateDgop = true;
      matugenTemplateFirefox = true;
      matugenTemplateGtk = true;
      matugenTemplateNiri = true;
      # matugenTemplatePywalfox = true;
      # matugenTemplateQt5ct = true; # Qt uses GTK theme
      # matugenTemplateQt6ct = true;
      matugenTemplateVesktop = true;
      # matugenTemplateVscode = true;
    };

    programs.alacritty = lib.mkIf dmsEnabled {
      settings.general.import = [
        (config.xdg.configHome + "/alacritty/dank-theme.toml")
      ];
    };

    # firefox (pywalfox)
    # pywalfox extension is installed at firefox configs
    home.packages = lib.mkIf dmsEnabled [ pkgs.pywalfox-native ];
    home.activation = {
      pywalfoxInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${lib.getExe pkgs.pywalfox-native} install > /dev/null 2>&1
      '';
    };
    home.file.".cache/wal/colors.json".source = lib.mkIf dmsEnabled (config.lib.file.mkOutOfStoreSymlink (config.home.homeDirectory + "/.cache/wal/dank-pywalfox.json"));

    # niri
    xdg.configFile."niri/config.kdl".text = ''
      include "dms/colors.kdl"
    '';

    programs.vesktop = lib.mkIf dmsEnabled {
      vencord.settings.enabledThemes = [
       "dank-discord.css"
      ];
    };
  };
}
