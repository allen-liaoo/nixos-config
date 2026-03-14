{...}: {
  sops = {
    defaultSopsFile = ./.sops.yaml;
    validateSopsFiles = true;
    
    age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key" # see host services.openssh config
    ];
    # age.keyFile = "/persist/sops/age/keys.txt";

    secrets = {
      # "github_deploy_key" = {
      #   sopsFile = ../../secrets/github-deploy-key.yaml;
      #   owner = "root";
      #   group = "root";
      #   mode = "0400";
      #   neededForUsers = true;
      # };
    };
  };
}
