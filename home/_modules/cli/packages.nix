{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    bat
    eza
    fd
    fzf
    ripgrep
    just
    trashy
  ];

  programs.fish = {
    shellAliases = {
      "cat" = "bat --paging=never";
    };
    shellAbbrs = {
      "js" = "just";
      "tr" = "trash"; # equiv to trash put
      "trl" = "trash list";
    };
  };
}
