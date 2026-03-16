{ config, pkgs, lib, customLib, ... }:

{
  imports = customLib.importDir ./. ++ [
    ./../common/default.nix
  ];

  home.username = "pig";
  home.homeDirectory = "/home/pig";

  home.packages = with pkgs; [
  ];

  programs.home-manager.enable = true;


  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        identityFile = config.sops.secrets.nixos_config_deploy.path;
      };
    };
  };
}
