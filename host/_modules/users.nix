{ lib, ... }:

{
  # required for sops-nix to use sops-install-secrets-for-users,service
  # instead of activation script; useful for impermanence to declare service order
  # experimental; differ from nixos's user setup script (which adds all users to "users" group)
  systemd.sysusers.enable = true;
}
