{ lib, customLib, config, ... }:
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableInteractive = true; # only when interactive

    settings = {
      format = lib.concatStrings [
        "$shell"
        "$username"
        "$directory"
        "$character"
      ];
    
      right_format = lib.concatStrings [
        "$container"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$git_metrics"
      ];
    
      username = {
        show_always = false;
      };
    
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
    
      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style)";
      };
    
      git_metrics = {
        disabled = false;
      };
    
      cmd_duration = {
        disabled = false;
        min_time = 50;
        show_milliseconds = true;
        format = "[$duration]($style) ";
      };
    
      status = {
        disabled = false;
      };
    
      shell = {
        disabled = false;
        style = "#696969";
        fish_indicator = "";
        format = "[$indicator]($style)";
        bash_indicator = "bsh ";
        zsh_indicator = "zsh ";
        unknown_indicator = "unknown shell ";
      };
    };
  };
}
