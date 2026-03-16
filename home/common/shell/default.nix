{ pkgs, customLib, ... }:

{
  imports = customLib.importDir ./.;
}
