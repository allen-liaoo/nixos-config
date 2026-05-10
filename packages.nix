{
  pkgs ? import <nixpkgs> { },
}:

{
  typst-mcp = pkgs.python3Packages.callPackage ./pkgs/typst-mcp/typst-mcp.nix rec {
    typst = pkgs.typst;
    typst-docs = pkgs.callPackage ./pkgs/typst-mcp/typst-docs.nix {
      typst = typst;
    };
    mcp = pkgs.python3Packages.callPackage ./pkgs/typst-mcp/mcp.nix { };
  };
  wavefox = pkgs.callPackage ./pkgs/wavefox.nix { };
}
