{ config, pkgs, lib, aln, ... }:

{
  imports = aln.lib.listDirFiles ./. ++ [
    ../_modules
  ];
}
