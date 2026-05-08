# Status: Config not working
{
  lib,
  config,
  pkgs,
  alnLib,
  ...
}:

let
  fcitx5-pkg = pkgs.kdePackages.fcitx5-with-addons;
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      fcitx5-with-addons = fcitx5-pkg;
      waylandFrontend = true;
      addons = with pkgs; [ fcitx5-rime ];
      settings = {
        inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "rime";
        };
        globalOptions = {
          Hotkey = {
            EnumerateWithTriggerKeys = true;
            EnumerateSkipFirst = false;
            ModifierOnlyKeyTimeout = 250;
          };
        };
      };
    };
  };
  # Relevant: https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland

  xdg.dataFile."fcitx5/rime/default.custom.yaml".source = config.lib.file.mkOutOfStoreSymlink (
    alnLib.outOfStoreRelToRoot config.home.homeDirectory ./default.custom.yaml
  );
  xdg.dataFile."fcitx5/rime/bopomofo.custom.yaml".source = config.lib.file.mkOutOfStoreSymlink (
    alnLib.outOfStoreRelToRoot config.home.homeDirectory ./bopomofo.custom.yaml
  );

  aln.niri.configFile."fcitx5" = {
    enable = false; # with config.i18n.inputMethod; lib.optionalString (enable && (type == "fcitx5"));
    content = ''
      binds {
        Ctrl+Space hotkey-overlay-title="Switch input method" {
          spawn "${lib.getExe config.i18n.inputMethod.fcitx5.fcitx5-with-addons}" "-t";
        }
      }
    '';
  };
}
