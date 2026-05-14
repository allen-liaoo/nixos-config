{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.alacritty = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.alacritty;
    settings = {
      general = {
        live_config_reload = true;
        # dms managed matugen theme
        import = lib.optionals config.programs.dank-material-shell.enable [
          (config.xdg.configHome + "/alacritty/dank-theme.toml")
        ];
      };
      window = {
        padding = {
          x = 8;
          y = 8;
        };
        decorations = "None";
        opacity = lib.mkForce 0.75;
      };
      cursor.style.shape = "Block";
      terminal.osc52 = "CopyPaste";
    };
  };

  programs.dank-material-shell.settings.matugenTemplateAlacritty = true;

  aln.niri.configFile."alacritty" = {
    enable = true;
    content = ''
      binds {
        Mod+T hotkey-overlay-title="Open a Terminal" {
          spawn "${lib.getExe config.programs.alacritty.package}";
        }
      }
      window-rule { 
        match app-id=r#"Alacritty"#
        // Open terminal in single column
        open-maximized false 
        open-maximized-to-edges false
        background-effect {
          blur true
          xray true
        }
      }
    '';
  };
}
