{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    bat
    fd
    fzf
    gtrash
    ripgrep
    just
  ];

  programs.fish = {
    shellAliases = {
      cat = "bat --paging=never";
    };
    shellAbbrs = {
      js = "just";
      tr = "gtrash put";
    };
  };
}
