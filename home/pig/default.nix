{ config, pkgs, lib, aln, ... }:

{
  imports = aln.lib.listDirFiles ./. ++ [
    ../common.nix
    ../sops_nix_config_deploy.nix
    ../modules/services
  ];
}
