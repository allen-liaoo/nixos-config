{
  pkgs ? import <nixpkgs> { },
}:

{
  typst-mcp = pkgs.python3Packages.callPackage ./pkgs/typst-mcp.nix rec {
    typst = pkgs.typst;
    typst-docs = pkgs.callPackage ./pkgs/typst-docs.nix {
      typst = typst;
    };
    mcp = pkgs.python3Packages.callPackage ./pkgs/mcp.nix { };
  };
  wavefox = pkgs.callPackage ./pkgs/wavefox.nix { };
}
