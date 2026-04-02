{ config, lib, aln, ... }: {
  sops = {
    # User expects host to decrypt and store its age key for use with sops-nix in home-manager
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    # Secret for deploying to this repo
    secrets = lib.optionalAttrs (aln.ctx.user.can.deployNixConfig) {
      "nix_config_deploy" = {
        sopsFile = aln.lib.relToRoot "secrets/common.yaml";
        mode = "0400";
        path = "${config.home.homeDirectory}" + "/.ssh/nix_config_deploy";
      };
    };
  };
}
