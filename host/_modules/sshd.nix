{ aln, ...}:
{
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };

    # Must generate host ssh key for sops
    # host will be able to decrypt user age keys and other host-level secrets
    hostKeys = [
      {
        path = if aln.ctx.host.hasTags [ "impermanent" ] then "/persist/etc/ssh/ssh_host_ed25519_key" else "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
