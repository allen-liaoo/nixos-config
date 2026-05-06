{ config, inputs, lib, alnLib, ctx, ... }: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    # User expects host to decrypt and store its age key for use with sops-nix in home-manager
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    # Secret for deploying to this repo
    secrets = lib.optionalAttrs (ctx.user.can.deployNixConfig) {
      "nix_config_deploy" = {
        sopsFile = alnLib.relToRoot "secrets/user/common.yaml";
        mode = "0400";
        path = "${config.home.homeDirectory}" + "/.ssh/nix_config_deploy";
      };
    };
  };
}
