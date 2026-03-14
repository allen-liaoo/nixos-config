{...}: {
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    validateSopsFiles = true;
    
    age.sshKeyPaths = [
      # USE STRINGS, DONT NOT USE PATHS (otherwise it gets written to nix store unencrypted)
      "/etc/ssh/ssh_host_ed25519_key" # see host services.openssh config
    ];
    # age.keyFile = "/persist/sops/age/keys.txt";

    secrets = {
      "ssh/github_personal" = {
        owner = "pig";# TODO: Change
        #group = "root";
        mode = "0400";
        neededForUsers = true;
      };
    };
  };
}
