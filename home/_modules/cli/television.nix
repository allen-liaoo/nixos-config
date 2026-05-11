{
  lib,
  pkgs,
  ...
}:

let
  tvCables = pkgs.fetchFromGitHub {
    owner = "alexpasmantier";
    repo = "television";
    rev = "0.15.6";
    hash = "sha256-vA9eUzgkfh1UEjTfswJaWe0Z20xUqx29nunPIQs7oyc=";
    sparseCheckout = [
      "/cable/unix"
    ];
  };
  cable = c: {
    ${c} = builtins.fromTOML (builtins.readFile "${tvCables}/cable/unix/${c}.toml");
  };
in
{
  programs.television = {
    enable = true;
    enableFishIntegration = true;
    channels = lib.mkMerge [
      (cable "channels")
      (cable "files") # fd
      (cable "fish-history") # fish
      (cable "fonts") # fc-list
      (cable "journal") # journalctl
      (cable "man-pages") # apropos, man
      (cable "text") # rg
    ]; # most requires bat
  };

  programs.fish.shellAbbrs = {
    "tvc" = "tv channels";
    "tvt" = "tv text";
    "tvj" = "tv journal";
  };

  programs.nix-search-tv = {
    enable = true;
    enableTelevisionIntegration = true;
    settings = {
      indexes = ["nixpkgs" "nixos" "home-manager" "nur" "noogle"];
    };
  };
}
