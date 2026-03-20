{ lib, aln, ... }:

# Only run services on guinea
lib.optionalAttrs (aln.ctx.host == aln.inventory.hosts.guinea) {
  imports = aln.lib.listDirFiles ./. ++ aln.lib.listSubdirs ./.;
}
