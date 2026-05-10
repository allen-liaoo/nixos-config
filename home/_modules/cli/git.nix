{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      push.autoSetupRemote = true;
    };
    attributes = [
      "*.pdf binary"
      "*.png binary"
      "*.jpg binary"
      "*.jpeg binary"
      "*.webp binary"
    ];
  };

  programs.fish.shellAbbrs = {
    g   = "git";
    gs  = "git status";
    ga  = "git add";
    gb  = "git branch";
    gch = "git checkout";
    gc  = "git commit -m";
    gd  = "git diff";
    gf  = "git fetch";
    gp  = "git push";
    gpl = "git pull";
    grb = "git rebase";
    gm  = "git merge";
    gl  = "git log";
  };
}
