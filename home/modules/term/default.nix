{ pkgs, customLib, ... }:

{
  imports = customLib.importDir { dir = ./.; };
}
