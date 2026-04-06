{ aln, inputs, ... }:

{
  imports = aln.lib.listDirFiles ./. ++ aln.lib.listSubdirs ./. ++ [
    ../_modules
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];
}
