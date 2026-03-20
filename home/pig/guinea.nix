{ aln, lib, ... }: 

lib.optionalAttrs (aln.ctx.host == aln.inventory.hosts.guinea) {
    imports = [ ../_modules/services ];
}
