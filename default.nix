# for the NUR
{ pkgs ? import <nixpkgs> {} }:

pkgs.lib.fix (self: {
  typst-docs = pkgs.callPackage ./pkgs/typst-docs.nix {
    typst = pkgs.typst;
  };

  typst-mcp = pkgs.python3Packages.callPackage ./pkgs/typst-mcp.nix {
    typst = pkgs.typst;
    typst-docs = self.typst-docs;
  };
})
