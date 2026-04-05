{ lib, pkgs, config, aln, ... }:

{
  # required for sops-nix to use sops-install-secrets-for-users.service instead of an activation script
  # which is used for ordering services (i.e. with impermanence)
  services.userborn.enable = true;
  
  users.users = lib.mergeAttrsList (map (user: {
    ${user.name} = {
      isNormalUser = !(user.hasTag.system-user);
      extraGroups = user.groups;
      linger = user.hasTag.linger;
      hashedPasswordFile = config.sops.secrets."passwd_${user.name}".path;
    };
  }) aln.ctx.host.users);

  # enable sudoers to use some commands without sudo
  security.sudo = {
    enable = true;
    extraRules = [{
      groups = [ "wheel" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl suspend";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/shutdown";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/reboot";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/poweroff";
          options = [ "NOPASSWD" ];
        }
      ];
    }];
  };
}
