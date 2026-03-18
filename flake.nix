{
  description = "NixOS Multi-Host & Multi-User Configuration";

  outputs = { nixpkgs, ... } @ inputs: 
  let 
    lib = nixpkgs.lib;
    meta = import ./meta.nix { inherit lib; };
    # my namespace; everything I define will be accessible in "aln" attr of module inputs
    mkAln = ctx: {
      inherit meta;
      lib = import ./lib { inherit lib; };
      ctx = ctx // {
        hostName = ctx.hostName or "default";  # default for non-nixos
        userName = ctx.userName or null;
      };
    };
  in
  {
    nixosConfigurations = lib.genAttrs meta.hostNames (
      hostName:
      let host = meta.hosts."${hostName}"; in 
      lib.nixosSystem {
        specialArgs = { 
          inherit inputs lib;
          aln = mkAln { inherit hostName; };
        };
        system = host.system;
        modules = with inputs; [
          ./host/${hostName}

          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          # If using HM as a NixOS Module (We dont as we want HM to be usable in other OSes)
          # home-manager.nixosModules.home-manager
          quadlet-nix.nixosModules.quadlet
        ];
      }
    );
    homeConfigurations = lib.listToAttrs (
      map ({ userName, hostName }: {
        name = "${userName}@${hostName}";
        value = inputs.home-manager.lib.homeManagerConfiguration {
          # legacy packaging (flat) instead of nested (import nixpkgs)
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          # pull inputs into args of home submodules
          extraSpecialArgs = { 
            inherit inputs;
            aln = mkAln { inherit hostName; inherit userName; };
          };
          modules = with inputs; [
            ./home/${userName}

            quadlet-nix.homeManagerModules.quadlet
            sops-nix.homeManagerModules.sops
          ];
        };
      }) meta.userHostPairs
    );
  };

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

    quadlet-nix = {
      url = "github:SEIAROTg/quadlet-nix";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
