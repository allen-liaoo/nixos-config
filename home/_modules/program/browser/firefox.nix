{ lib, pkgs, config, ... }@args:

let
  # TODO: remove once in unstable
  pywalfox-native = (import (pkgs.fetchFromGitHub {
    owner = "allen-liaoo";
    repo = "nixpkgs";
    rev = "update-pywalfox-native";
    hash = "sha256-ZE+UN4OoJkBtl5tE9HQ4F0TXXH/zqRytlxpTrYIp0f8=";
  }) { system = pkgs.stdenv.hostPlatform.system; }).pywalfox-native;
in
{
  imports = [
    (import ./firefox/mkModule { 
      modulePath = [ "programs" "firefox" ];
    })
  ];

  programs.firefox = lib.mkMerge [
    (import ./firefox/config { inherit (args) lib pkgs-nur; })
    {
      pywalfox = {
        enable = true;
        package = pywalfox-native;
      };
      profiles.default = {
        wavefox = {
          enable = true;
        };
      };
    }
  ];

  home.packages = [ pywalfox-native ];

  # setup DMS managed matugen theme
  home.file.".cache/wal/colors.json".source = config.lib.file.mkOutOfStoreSymlink (config.home.homeDirectory + "/.cache/wal/dank-pywalfox.json");
}
