{ alnLib, inputs, ... }:

{
  imports =
    alnLib.listDirFiles ./.
    ++ alnLib.listSubdirs ./.
    ++ [
      ../_modules
    ];
}
