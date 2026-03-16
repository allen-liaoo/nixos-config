{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    
    interactiveShellInit = ''
      set fish_greeting
    '';

    shellInit = builtins.readFile ./config.fish;
  };

  # fish as login shell breaks system, so use bash and launch fish if parent process is fish
  # see: https://nixos.wiki/wiki/Fish#Setting_fish_as_your_shell
  programs.bash.enable = true;
  programs.bash.bashrcExtra = ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
  '';
}
