{ lib, aln, ... }:

{
  imports = aln.lib.listDirFiles ./. ++ aln.lib.listSubdirs ./.;
}
