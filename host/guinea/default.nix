{ customLib, ... }:

{
  imports = customLib.importDir { dir = ./.; } ++ customLib.importSubdirs ./. ++ [
    ../modules/common.nix
  ];
}
