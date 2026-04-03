{ lib, aln, ... }:

{
  imports = lib.optionals (aln.ctx.host.is.gui) (aln.lib.listDirFiles ./. ++ aln.lib.listSubdirs ./.);
}
