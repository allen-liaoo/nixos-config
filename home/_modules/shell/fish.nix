{ pkgs, lib, config, ... }:
{
  config = {
    programs.fish = {
      enable = true;
      generateCompletions = true;
      
      interactiveShellInit = ''
        # disable fish greeting
        set fish_greeting

        fish_default_key_bindings

        # n dots = go up (n-1) dirs: ... = cd ../../
        function multicd
          echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
        end
        abbr --add dotdot --regex '^\.\.+$' --function multicd
 
        # choose theme based on environment variable
        function apply-my-theme --on-variable=fish_theme
          fish_config theme choose $fish_theme
        end
      '' + lib.optionalString config.programs.yazi.enable ''
        # Yazi specific init (replaces the need for abbreviation
        # press q to quit with auto cd; press Q to quit without cd
        function y
        	set tmp (mktemp -t "yazi-cwd.XXXXXX")
        	yazi $argv --cwd-file="$tmp"
        	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        		builtin cd -- "$cwd"
        	end
        	rm -f -- "$tmp"
        end
      '';
  
      shellAbbrs = {
        c = "cd";
        ll = "ls -lAh";
	      
        # programs that are only pkgs or should be systemwide
        js = "just";
        v = "vim";

      } // lib.optionalAttrs config.programs.git.enable {
        g = "git";
        gs = "git status";
        ga = "git add";
        gb = "git branch";
        gch = "git checkout";
        gc = "git commit -m";
        gd = "git diff";
        gf = "git fetch";
        gp = "git push";
        gpl = "git pull";
        grb = "git rebase";
        gm = "git merge";
        gl = "git log";

      } // lib.optionalAttrs config.programs.zellij.enable {
        zj = "zellij";
      };
    };
  
    # fish as login shell breaks system, so use bash and launch fish if parent process is fish
    # see: https://nixos.wiki/wiki/Fish#Setting_fish_as_your_shell
    programs.bash.enable = true;
    programs.bash.bashrcExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        SHELL=${pkgs.fish}/bin/fish exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
}
