{ alnLib, ... }:

{
  imports = alnLib.listDirFiles ./. ++ alnLib.importExcept (alnLib.listSubdirs ./.) [ "firefox" ];
}
