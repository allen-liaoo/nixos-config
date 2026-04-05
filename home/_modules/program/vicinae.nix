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
      close_on_focus_loss = true;
      consider_preedit = true;
      pop_to_root_on_close = true;
      favicon_service = "twenty";
      search_files_in_root = true;
  
      favorites = [
        "core:search-emojis"
        #"@mmazzarolo/store.raycast.unicode-symbols:index"
        "files:search"
        "clipboard:history"
      ];
  
      providers = {
        clipboard = {
          preferences = {
            monitoring = false;
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
            report-bug.enabled = false;
            search-emojis.alias = "e";
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
          hibernate.enabled = false;
          lock.enabled = false;
          sleep.enabled = false;
          soft-reboot.enabled = false;
          suspend.enabled = false;
        };
      };
    };
  };
}
