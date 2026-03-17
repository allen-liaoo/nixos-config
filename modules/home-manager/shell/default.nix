{ pkgs, customLib, ... }:

{
  imports = customLib.importDir ./. ++ customLib.importSubdirs ./.;
}
