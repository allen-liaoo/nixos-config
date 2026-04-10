{ lib, pkgs-unstable, ...}: 

{
  home.packages = with pkgs-unstable; [
    github-copilot-cli
  ];
}
