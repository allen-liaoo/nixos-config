{ pkgs, lib, config, ... }:
{
  config = {
    programs.fish = {
      enable = true;
      
      interactiveShellInit = ''
        set fish_greeting
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
        ga = "git add .";
        gb = "git branch";
        gch = "git checkout";
        gc = "git commit -m";
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
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
}
