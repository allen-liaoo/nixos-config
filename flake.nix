{
  description = "NixOS Multi-Host & Multi-User Configuration";

  inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.11";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... } @ inputs: 
    let 
      hostList = [
        "guinea"
      ];
      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations = lib.genAttrs hostList (
        hostName:
        lib.nixosSystem {
          specialArgs = { inherit inputs; inherit lib; };
          system = "x86_64-linux";
          modules = [
            ./host/${hostName}/configuration.nix
  
            inputs.disko.nixosModules.disko
            inputs.home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
          ];
        }
      );

      homeConfigurations = {
        "pig" = inputs.home-manager.lib.homeManagerConfiguration {
          # legacy packaging (flat) instead of nested (import nixpkgs)
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          # pull inputs into args of home submodules (if needed)
          extraSpecialArgs = { 
            inherit inputs;
            customLib = import ./lib { inherit (nixpkgs) lib; };
          };
          modules = [
            ./home/pig/default.nix
            inputs.sops-nix.homeManagerModules.sops
          ];
        };
      };
    };
}
