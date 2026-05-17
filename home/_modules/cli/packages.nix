{
  pkgs,
  inputs,
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

    inputs.nix-packages.legacyPackages.${pkgs.stdenv.hostPlatform.system}.television
  ];

  programs.fish = {
    shellAliases = {
      cat = "bat --paging=never";
    };
    shellAbbrs = {
      js = "just";
      tr = "gtrash put";
      tvc = "tv channels";
      tvj = "tv journal";
      tvn = "tv nix-search-tv";
      tvt = "tv text";
    };
  };
}
