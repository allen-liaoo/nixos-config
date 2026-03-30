{ config, lib, aln, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = 
    # Github access for this repository
    # NOTE: use gh_nix_config as git's remote url to avoid key conflicts with other git repositories
    lib.optionalAttrs (aln.ctx.user.can.deployNixConfig) {
      "gh_nix_config" = {
        hostname = "github.com";
        identityFile = config.sops.secrets.nix_config_deploy.path;
        addKeysToAgent = "yes";
      };
    } // {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "yes";
        checkHostIP = true;
        serverAliveCountMax = 3;
        serverAliveInterval = 60; # sec
        controlMaster = "auto"; # connection multiplexing
        controlPath = "/tmp/ssh-%r@%h:%p"; # remote username, host, port
        controlPersist = "10m";
      };
    };
  };
}
