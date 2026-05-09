{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  nvimxPkg =
    with inputs.nvimx;
    makeNixvimWithModule (pkgs.stdenv.hostPlatform.system) {
      nvimx.treesitter.enableAllGrammars = true;
      nvimx.shells.enable = true;
    };
in
{
  home.packages = [
    nvimxPkg
  ];

  programs.fish.shellAliases = {
    "v" = lib.mkForce "nvim";
    "vi" = lib.mkForce "nvim";
    "vim" = lib.mkForce "nvim";
  };

  home.sessionVariables = {
    "EDITOR" = lib.mkForce "nvim";
    "VISUAL" = lib.mkForce "nvim";
  };
}
