{ alnLib, ... }:

{
  imports =
    alnLib.listDirFiles ./.
    ++ alnLib.listSubdirs ./.
    ++ [
      ../_modules
    ];
}
