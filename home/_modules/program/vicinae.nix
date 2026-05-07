{ lib, inputs, pkgs, config, ... }:

let
  # Raycast Extensions github
  # https://github.com/raycast/extensions
  # Note: Do not move to flake input, as we want sparse checkout
  # See: https://github.com/vicinaehq/vicinae/blob/main/nix/mkRayCastExtension.nix
  rcRev = "3ec994afcd05b2b6258b3b71ab8b19d6b6f1e0e4"; # commit hash
  rcSha = "sha256-sltBhjniJvRZ6zys1lmKnz9UNfS2AS47uZilV/j6XZY="; # hash of tarball at the rev; to obtain, run flake with rev and dummy sha value
in
{
  imports = [
    inputs.vicinae.homeManagerModules.default
  ];

  # vicinae is ride or die for niri
  systemd.user.services.vicinae = {
    Unit = {
      After = [ "niri.service" ];
      BindsTo = [ "niri.service" ];
    };
  };

  services.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
      environment = {
        USE_LAYER_SHELL = 1;
      };
    };

    extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
      nix
      player-pilot
      ssh
      #systemd # not supported currently
    ] ++ 
    # raycast extensions
    ([
      "unicode-symbols"
    ] |>
      map (ext: 
        inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.mkRayCastExtension {
          name = ext;
          rev = rcRev;
          sha256 = rcSha;
        }
      ));

    settings = {
      theme = { # see below
        dark.name = "matugen";
        light.name = "matugen";
      };

      close_on_focus_loss = true;
      consider_preedit = true;
      pop_to_root_on_close = true;
      favicon_service = "twenty";
      search_files_in_root = true;

      launcher_window = {
        opacity = 0.4;
        client_side_decorations.enabled = true; #false;
      };

      font.normal.size = 11;
  
      favorites = [
        "clipboard:history"
        "files:search"
        "core:search-emojis"
        "@mmazzarolo/unicode-symbols:index"
      ];
  
      providers = {
        "@mmazzarolo/unicode-symbols".entrypoints.index.alias = "u";
        applications = {
          preferences = {
            defaultAction = "launch";
          };
          entrypoints = {
            firefox.alias = "b";
          };
        };
        clipboard = {
          preferences = {
            monitoring = true;
            encryption = true; # TODO: keychain?
            eraseOnStartup = true;
            ignorePasswords = true;
          };
          entrypoints.history.alias = "c";
        };
        core = {
          entrypoints = {
            about.enabled = false;
            documentation.enabled = false;
            keybind-settings.enabled = false;
            list-extensions.enabled = false;
            manage-fallback.enabled = false;
            oauth-token-store.enabled = false;
            open-config-file.enabled = false;
            open-default-config.enabled = false;
            report-bug.enabled = true;
            search-emojis = { enabled = true; alias = "e"; };
            sponsor.enabled = false;
          };
        };
        developer.enabled = false;
        files = {
          preferences.watecherPaths = config.home.homeDirectory + "/Downloads";
          entrypoints.search.alias = "f";
        };
        manage-shortcuts.entrypoints.create.enabled = false;
        power.entrypoints = {
          lock = { enabled = true; alias = "l"; };
          suspend = { enabled = true; alias = "s"; };
          power-off = { enabled = true; alias = "p"; };
          reboot = { enabled = true; alias = "r"; };
          hibernate.enabled = false;
          sleep.enabled = false;
          soft-reboot.enabled = false;
        };
      };
    };
  };

  aln.niri.configFile."vicinae" = {
    enable = true;
    content = ''
      binds {
        Mod+X repeat=false { spawn "${lib.getExe config.services.vicinae.package}" "toggle"; }
      }
      // launcher
      layer-rule {
        match namespace=r#"^vicinae$"#
        background-effect {
          blur true
          xray false
        }
      }
      // vicinae settings
      window-rule {
        match app-id="vicinae"
        background-effect {
          blur true
          xray true
        }
        geometry-corner-radius 5
      }
    '';
  };


  aln.matugen.template."vicinae" = {
    enable = true;
    content = {
      input_path = inputs.vicinae.outPath + "/extra/matugen.toml";
      output_path = config.xdg.dataHome + "/vicinae/themes/matugen.toml";
      post_hook = "${lib.getExe config.services.vicinae.package} theme set matugen";
    };
  };
}
