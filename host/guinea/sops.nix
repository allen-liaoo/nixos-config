{config, ...}: {
  sops = let 
      secrets_dir = ./../../secrets;
  in {
    defaultSopsFile = secrets_dir + /common.yaml;
    age.sshKeyPaths = [
      # USE STRINGS, DONT NOT USE PATHS (otherwise it gets written to nix store unencrypted)
      "/etc/ssh/ssh_host_ed25519_key" # see host services.openssh config
    ];

    secrets = {
      "nixos_config_deploy" = {
        key = "nixos_config_deploy";
        owner = "root";
        group = "root";
        mode = "0400";
      };

      "age_key_pig" = {
        sopsFile = secrets_dir + /host/guinea.yaml;
        key = "age_key/pig";
        owner = config.users.users."pig".name;
        mode = "0400";
        path = "/home/pig/age_key";
      };
    };
  };
}
