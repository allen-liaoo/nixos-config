# https://github.com/nix-community/comma
# https://github.com/nix-community/nix-index-database

{
  inputs,
  ...
}:

{
  imports = [
    inputs.nix-index-database.homeModules.default
  ];

  programs.nix-index-database.comma.enable = true;
}
