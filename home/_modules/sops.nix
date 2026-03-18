{ config, aln, ... }: {
  sops = {
    # defaultSopsFile = ./../../secrets/user/${config.home.username}.yaml;
    
    # User expects host to decrypt and store its age key for use with sops-nix in home-manager
    age.keyFile = "/home/${config.home.username}/age_key";
  };
}
