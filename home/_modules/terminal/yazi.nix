{
  config,
  ...
}:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    # TODO: Consider linking toml files
    # to share config across hosts/homes? what about conditional opens?
    settings = {
      mgr = {
        show_hidden = false;
        sort_dir_first = true;
        sort_by = "extension";
        show_symlink = true;
      };

      # TODO: opener and open rules based on gui/headless
      #open.prepend_rules = [
      #{ mime = "text/plain"; use = "text"; }
      #{ name = "*"; use = "default_open"; }
      #];

      #opener = {
      #text = [{ run = "$EDITOR %s"; block = true; }];
      # default_open = [{ run = "xdg-open \"$@\""; orphan = true; }];
      #};
    };
  };
  # TODO: for wayland with alacritty, need ueberzugpp installed

  # Yazi specific init (replaces the need for abbreviation)
  # press q to quit with auto cd; press Q to quit without cd
  programs.fish.interactiveShellInit = ''
    function y
      set tmp (mktemp -t "yazi-cwd.XXXXXX")
      yazi $argv --cwd-file="$tmp"
      if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
      end
      rm -f -- "$tmp"
    end
  '';

  aln.matugen.template."yazi" = {
    enable = true;
    content = {
      input_path = config.aln.matugen.themesPath "yazi-theme.toml";
      output_path = config.xdg.configHome + "/yazi/theme.toml";
    };
    # no support for live reloading yet
  };
}
