{ aln, ... }:

lib.optionalAttrs (aln.ctx.host.is.gui) {
  # Stylix with gtk needs dconf enabled
  # https://github.com/nix-community/stylix/issues/139
  programs.dconf.enable = true;
}
