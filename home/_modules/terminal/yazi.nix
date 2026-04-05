{ ... }:
 
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
}
