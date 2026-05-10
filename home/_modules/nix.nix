{
  pkgs,
  ...
}:

{
  nix = {
    package = pkgs.nix; # necessary for generating nix.conf
    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
        "pipe-operators"
      ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
      persistent = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
}
