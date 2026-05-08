{ lib, alnLib }@args:

(lib.evalModules {
  specialArgs = args;
  modules = [
    ./schema.nix
    ./data.nix
  ];
}).config
