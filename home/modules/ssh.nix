{ config, ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      # Github access for this repository
      "allen-liaoo.github.com" = {
        hostname = "github.com";
        user = "allen-liaoo";
        identityFile = config.sops.secrets.nixos_config_deploy.path;
        addKeysToAgent = "yes";
      };
    };
  };
}
