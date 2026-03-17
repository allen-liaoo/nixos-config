{ config, ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      # Github access for this repository
      # NOTE: use gh_nix_config as git's remote url to avoid key conflicts with other repositories
      "gh_nix_config" = {
        hostname = "github.com";
        identityFile = config.sops.secrets.nixos_config_deploy.path;
        addKeysToAgent = "yes";
      };
    };
  };
}
