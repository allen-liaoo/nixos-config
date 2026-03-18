{ pkgs, ... }:

{
  # Need to install shell even if HM installs it 
  # However, for fish, setting it as login shell will cause some systemd services to break, so we use bash
  users.defaultUserShell = pkgs.bash;

  programs.fish.enable = true;
}
