{ alnLib, ... }:

{
  imports = alnLib.listDirFiles ./. ++ [
    ../_modules
  ];
}
