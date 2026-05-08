{ lib }@args:

import ./path.nix args
// import ./quadlet.nix args
// {
  # Callers that have pkgs use this: aln.lib.withPkgs pkgs
  #withPkgs = pkgs: import ./syspkg.nix (args // { inherit pkgs; });
}
