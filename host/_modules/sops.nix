{ config, lib, aln, ... }: {
  sops = let 
    secrets_dir = aln.lib.relToRoot "secrets";
  in {
    defaultSopsFile = aln.ctx.host.sopsFilePath;
    # Host SSH Keys are used to decrypt secrets
    # Each host is guaranteed to have a host key generated when first booted up (see host sshd config)
    # USE STRINGS, DONT NOT USE PATHS (otherwise it gets written to nix store unencrypted)
    age.sshKeyPaths = if aln.ctx.host.hasTags [ "impermanent" ] then [
      "/persist/etc/ssh/ssh_host_ed25519_key" 
    ] else [
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
        # expected to be in the default age key location
        # see home's shared sops.nix
        "age_key_${user.name}" = {
          key = "age/${user.name}";
          owner = user.name;
          mode = "0400";
          path = "/home/${user.name}/.config/sops/age/keys.txt";
        };

        # Add user password
        "passwd_${user.name}" = {
          key = "passwd/${user.name}";
          mode = "0400";
          neededForUsers = true;
        };
      }) aln.ctx.host.users)
    );
  };
}
