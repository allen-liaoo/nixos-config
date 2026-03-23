{ lib, aln, ... }:

# Only run services on guinea
lib.optionalAttrs (builtins.elem aln.ctx.host.name [
  aln.inventory.hosts.guinea.name
  aln.inventory.hosts.barrybenson.name
]) {
  imports = aln.lib.listDirFiles ./. ++ aln.lib.listSubdirs ./.;
}
