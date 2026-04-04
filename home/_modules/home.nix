{ lib, pkgs, inputs, aln, ... }:

{
  programs.home-manager.enable = true;

  home.username = aln.ctx.user.name;
  home.homeDirectory = "/home/${aln.ctx.user.name}";

  home.packages = with pkgs; [ ];

  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
    persistent = true;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
}
