{ config, lib, aln, ... }: {
  sops = let 
    secrets_dir = aln.lib.relToRoot "secrets";
  in {
    defaultSopsFile = secrets_dir + /host/${aln.ctx.hostName}.yaml;
    # Host SSH Keys are used to decrypt secrets
    # Each host is guaranteed to have a host key generated when first booted up (see host sshd config)
    age.sshKeyPaths = [
      # USE STRINGS, DONT NOT USE PATHS (otherwise it gets written to nix store unencrypted)
      "/etc/ssh/ssh_host_ed25519_key" 
    ];

    secrets = {
      "nix_config_deploy" = {
        sopsFile = secrets_dir + /common.yaml;
        key = "nix_config_deploy";
        owner = "root";
        group = "root";
        mode = "0400";
      };

    } // (lib.mergeAttrsList (
      map (user: {
        # Add user age key, which the user would use to decrypt secrets
        # see /home/modules/sops.nix
        "age_key_${user.name}" = {
          key = "age/${user.name}";
          owner = user.name;
          mode = "0400";
          path = "/home/${user.name}/age_key";
        };

        # Add user password
        "passwd_${user.name}" = {
          key = "passwd/${user.name}";
          mode = "0400";
          neededForUsers = true;
        };
      }) (aln.meta.usersForHost aln.ctx.hostName))
    );
  };
}
