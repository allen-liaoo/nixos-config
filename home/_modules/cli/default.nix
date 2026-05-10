{ alnLib, ... }:

{
  imports = alnLib.listDirFiles ./. ++ alnLib.listSubdirs ./.;
}
