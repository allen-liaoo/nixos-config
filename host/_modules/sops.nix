{ config, lib, aln, ... }: {
  sops = let 
    secretsDir = aln.lib.relToRoot "secrets";
  in {
    useSystemdActivation = true; # required by services that need to be before/after secrets are decrypted (i.e. impermanence)
    # adds "sops-install-secrets.service"
    # for secrets flagged as neededForUsers, we also need to enable userborn (see users.nix)

    # Host SSH Keys are used to decrypt secrets
    # Each host is guaranteed to have a host key generated when first booted up (see host sshd config)
    # USE STRINGS, DONT NOT USE PATHS (otherwise it gets written to nix store unencrypted)
    age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key" 
    ]; # see impermanence.nix for override

    secrets = lib.mergeAttrsList (
      map (user: let
        sopsFile = secretsDir + /user/${user.name}/for_hosts.yaml;
      in {
        # Add user age key, which the user would use to decrypt secrets
        # expected to be in the default age key location
        # see home's shared sops.nix
        "age_key_${user.name}" = {
          inherit sopsFile;
          key = "age";
          owner = user.name;
          mode = "0400";
          path = "/home/${user.name}/.config/sops/age/keys.txt";
        }; # see impermanence.nix for overriding path

        # Add user password
        "passwd_${user.name}" = {
          inherit sopsFile;
          key = "passwd";
          mode = "0400";
          neededForUsers = true;
        };
      }) aln.ctx.host.users);
  };

  # when sops-nix creates the user age key file along with its parent dirs on first boot,
  # it acts as root, so the parent dirs are owned by root even if secret is owned by user
  # to curcumvent that, we create directories if it is missing (d flag), and set correct file perms
  systemd.tmpfiles.rules = lib.concatMap (user: [
    "d /home/${user.name}/.config          0755 ${user.name} ${user.name} -"
    "d /home/${user.name}/.config/sops     0700 ${user.name} ${user.name} -"
    "d /home/${user.name}/.config/sops/age 0700 ${user.name} ${user.name} -"
  ]) aln.ctx.host.users;

}
