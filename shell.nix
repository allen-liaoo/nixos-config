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
          nixosConfKey = if userName != "" then hostName else ""; # nixos config only exists if user is declared
          hmConfKey = if userName != "" then "${userName}@${hostName}" else "";
        };
      };

      nixvimPkg = inputs.nvimx.makeNixvimWithModule system nixvimModule;
    in pkgs.mkShell {
      packages = [ nixvimPkg ];
      shellHook = ''exec ${pkgs.fish}/bin/fish'';
    };

  # NixOS host shells: dev-hostname
  nixosShells = lib.listToAttrs (map
    (hostName: {
        name = "dev-${hostName}";
        value = mkDevShell { inherit hostName; };
      })
    inventory.nixosHostNames);

  # Home-manager user shells: dev-hostname@username
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
      shellHook = ''exec ${pkgs.fish}/bin/fish'';
    };
  }
)
