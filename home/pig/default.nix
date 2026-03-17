{ config, pkgs, lib, customLib, userName, ... }:

{
  imports = customLib.importDir ./. ++ [
    ../common.nix
  ];

  home.packages = with pkgs; [
  ];

  programs.home-manager.enable = true;
}
