{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = {
    programs.fish = {
      enable = true;
      generateCompletions = true;

      interactiveShellInit = ''
        # disable fish greeting
        set fish_greeting
        # disable command not found
        function fish_command_not_found; end

        fish_default_key_bindings
        fish_vi_key_bindings
        set fish_cursor_default block
        set fish_cursor_insert block blink

        # n dots = go up (n-1) dirs: ... = cd ../../
        function multicd
          echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
        end
        abbr --add dotdot --regex '^\.\.+$' --function multicd

        # choose theme based on environment variable
        function apply-my-theme --on-variable=fish_theme
          fish_config theme choose $fish_theme
        end
      '';

      shellAbbrs = {
        c = "cd";
        ll = "ls -lAh";
        js = "just"; # REMOVE
      };
    };

    # fish as login shell breaks system, so use bash and launch fish if parent process is not fish
    # see: https://nixos.wiki/wiki/Fish#Setting_fish_as_your_shell
    programs.bash.enable = true;
    programs.bash.initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        SHELL=${pkgs.fish}/bin/fish exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
}
