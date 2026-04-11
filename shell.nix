{ inputs, lib, inventory }:
system:
(let
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  # Build a nixvim shell for a given host/system
  mkDevShell = { hostName, userName ? "" }:
    let
      nixvimModule = {
        imports = [ inputs.nvimx.nixvimModules.nix ];
        
        nvimx.nixd = { # enable lsp to lookup options and pkgs
          nixpkgsName = "nixpkgs";
          nixosConfKey = if userName == "" then hostName else ""; # dont load nixos configs if using home manager
          hmConfKey = if userName != "" then "${userName}@${hostName}" else "";
        };
      };

      nixvimPkg = inputs.nvimx.makeNixvimWithModule system nixvimModule;
    in pkgs.mkShell {
      packages = [ nixvimPkg ];
    };

  # NixOS host shells: dev-hostname
  nixosShells = lib.listToAttrs (map
    (hostName: {
        name = "dev-${hostName}";
        value = mkDevShell { inherit hostName; };
      })
    inventory.nixosHostNames);

  # Home-manager user shells: dev-username@hostname
  homeShells = lib.listToAttrs (map
    ({ userName, hostName }: {
        name = "dev-${userName}@${hostName}";
        value = mkDevShell { inherit hostName userName; };
      })
    inventory.userHostPairs);
in
  nixosShells // homeShells //
  {
    sops = pkgs.mkShell {
      packages = with pkgs; [
        age
        sops
        ssh-to-age
      ];
    };
  }
)
