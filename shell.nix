{
  inputs,
  lib,
  inventory,
}:
system:
(
  let
    pkgs = inputs.nixpkgs.legacyPackages.${system};

    # Build a nixvim shell for a given host/system
    mkDevShell =
      {
        hostName,
        userName ? "",
      }:
      let
        nixvimModule = {
          nvimx.nix = {
            enable = true;
            nixd = {
              nixpkgsName = "nixpkgs";
              nixosConfKey = hostName; # would like to disable this but nixd does not support it
              hmConfKey = if userName != "" then "${userName}@${hostName}" else "";
            };
          };
          nvimx.configs.enable = true;
        };

        nixvimPkg = inputs.nvimx.makeNixvimWithModule system nixvimModule;
      in
      pkgs.mkShell {
        packages = [ nixvimPkg ];
      };

    # NixOS host shells: dev-hostname
    nixosShells = lib.listToAttrs (
      map (hostName: {
        name = "dev-${hostName}";
        value = mkDevShell { inherit hostName; };
      }) inventory.nixosHostNames
    );

    # Home-manager user shells: dev-username@hostname
    homeShells = lib.listToAttrs (
      map (
        { userName, hostName }:
        {
          name = "dev-${userName}@${hostName}";
          value = mkDevShell { inherit hostName userName; };
        }
      ) inventory.userHostPairs
    );
  in
  nixosShells
  // homeShells
  // {
    sops = pkgs.mkShell {
      packages = with pkgs; [
        age
        sops
        ssh-to-age
      ];
    };
  }
)
