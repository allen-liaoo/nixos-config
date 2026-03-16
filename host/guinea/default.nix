{ customLib, ... }:

{
  imports = customLib.importDir ./. ++ customLib.importSubdirs ./. ++ [
    ../modules
  ];
}
