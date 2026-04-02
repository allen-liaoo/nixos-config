{ lib, inputs, pkgs, config, ... }:

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
    #package = vicinaePatched;
    systemd = {
      enable = true;
      autoStart = true;
      environment = {
        USE_LAYER_SHELL = 1;
      };
    };

    extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
      ssh
      nix
    ];

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
