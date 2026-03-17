{ customLib, ... }:

{
  imports = customLib.importDir ./. ++ customLib.importSubdirs ./. ++ [
    ../common.nix
  ];
}
