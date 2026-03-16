{ config, pkgs, lib, customLib, userName, ... }:

{
  imports = customLib.importDir ./. ++ [
    ./../common/default.nix
  ];

  home.username = userName;
  home.homeDirectory = "/home/${userName}";

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
