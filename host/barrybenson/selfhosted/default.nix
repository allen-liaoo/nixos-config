{ lib, alnLib, ... }:

{
  imports =
    (alnLib.importExcept (alnLib.listDirFiles ./.) [ "secrets_dir.nix" ]) ++ alnLib.listSubdirs ./.;
}
