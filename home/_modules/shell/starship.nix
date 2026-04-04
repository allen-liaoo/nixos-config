{ lib, config, aln, ... }:
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
        "$nix_shell"
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

      character = {
        vimcmd_visual_symbol = "[❯❮](bold yelloa)";
      };
    
      username = {
        show_always = false;
        format = "[$user]($style) ";
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
        format = "[$indicator]($style)";
        fish_indicator = "";
        bash_indicator = "bsh ";
        zsh_indicator = "zsh ";
        unknown_indicator = "unknown shell ";
      };

      nix_shell = {
        disabled = false;
        format = "[$symbol]($style) ";
        symbol = if aln.ctx.host.is.gui
          then "" # nix nerd-font
          else "❄️";
      };
    };
  };
}
