{ inputs, lib, inventory }:
system:
(let
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  # Build a nixvim shell for a given host/system
  mkDevShell = { hostName, userName ? "" }:
    let
      nixvimModule = {
        imports = [ inputs.nvimx.nixvimModules.nix ];
        
        # Per-host/user nixd configuration
        # Can't get it to work with config in native nixvim
        lsp.luaConfig.post = let
          flakeExpr = ''(builtins.getFlake (builtins.toString ./.))'';
        in ''
          local lsp = vim.lsp
 
          lsp.config("nixd", {
            settings = {
              nixd = {
                nixpkgs = {
                  expr = "${flakeExpr}.inputs.nixpkgs.legacyPackages.\"${system}\"",
                },
                options = {
                  nixos = {
                    expr = "${flakeExpr}.nixosConfigurations.${hostName}.options",
                  },
                  ${if userName != "" then ''
                  ["home-manager"] = {
                    expr = "${flakeExpr}.homeConfigurations.\"${userName}@${hostName}\".options",
                  },'' else "" }
                },
              },
            },
          })
        
          lsp.enable("nixd")'';
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
