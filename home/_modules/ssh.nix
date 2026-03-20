{ config, lib, aln, ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks = 
    # Github access for this repository
    # NOTE: use gh_nix_config as git's remote url to avoid key conflicts with other git repositories
    lib.optionalAttrs (aln.ctx.user.can.deploy_nix_config) {
      "gh_nix_config" = {
        hostname = "github.com";
        identityFile = config.sops.secrets.nix_config_deploy.path;
        addKeysToAgent = "yes";
      };
    };
  };
}
