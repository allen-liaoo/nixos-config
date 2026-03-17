{ config, ... }: {
  sops = {
    # defaultSopsFile = ./../../secrets/user/pig.yaml;
    
    # User expects host to decrypt and store its age key for use with sops-nix in home-manager
    age.keyFile = "/home/pig/age_key";

    secrets = {
      "nix_config_deploy" = {
        sopsFile = ./../../secrets/common.yaml;
        mode = "0400";
        path = "${config.home.homeDirectory}" + "/.ssh/nix_config_deploy";
      };
    };
  };
}
