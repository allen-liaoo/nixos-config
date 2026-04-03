{
  description = "NixOS Multi-Host & Multi-User Configuration";

  outputs = { nixpkgs, nixpkgs-unstable, ... } @ inputs: 
  let 
    lib = nixpkgs.lib;
    alnLib = import ./lib { inherit nixpkgs; };
    inventory = import ./inventory { inherit lib alnLib; };
    # my namespace; everything I define will be accessible in "aln" attr of module inputs
    mkAln = ctx: {
      inherit inventory;
      lib = alnLib;
      ctx = import ./ctx.nix ({ inherit lib inventory; } // ctx);
    };
  in
  {
    nixosConfigurations = lib.genAttrs inventory.nixosHostNames (
      hostName:
      let host = inventory.hosts.${hostName}; in 
      lib.nixosSystem {
        specialArgs = { 
          inherit inputs lib;
          aln = mkAln { inherit hostName; };
        };
        system = host.system;
        modules = with inputs; [
          ./host/${hostName}

          dms.nixosModules.greeter
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
          quadlet-nix.nixosModules.quadlet
        ];
      }
    );

    homeConfigurations = lib.listToAttrs (
      map ({ userName, hostName }: {
        name = "${userName}@${hostName}";
        value = let
            system = inventory.hosts.${hostName}.system or inventory.systems.x86_linux;
          in inputs.home-manager.lib.homeManagerConfiguration {
          # legacy packaging (flat) instead of nested (import nixpkgs)
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = {
            # pull inputs into args of home submodules
            inherit inputs;
            pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
            pkgs-nur = inputs.nur.legacyPackages.${system};
            aln = mkAln { inherit hostName; inherit userName; };
          };
          modules = with inputs; [
            ./home/${userName}

            dms.homeModules.dank-material-shell
            quadlet-nix.homeManagerModules.quadlet
            sops-nix.homeManagerModules.sops
            stylix.homeModules.stylix
            vicinae.homeManagerModules.default
            vscode-server.nixosModules.home
            xremap.homeManagerModules.default
          ];
        };
      }) inventory.userHostPairs
    );

    devShells = lib.genAttrs inventory.systems (
      (system: {
        default = let 
          pkgs = nixpkgs.legacyPackages.${system};
        in pkgs.mkShell {
          packages = with pkgs; [
            age
            git
            just
            sops
            ssh-to-age
          ];
        };
      })
    );
  };

  nixConfig = {
    extra-substituters = [ "https://vicinae.cachix.org" ];
    extra-trusted-public-keys = [ "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=" ];
  };

  inputs = {
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dgop = { # for dms' system monitor
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "home-manager"; # dependency not needed for use
      inputs.home-manager.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.11";
    };

    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix = {
      url = "github:SEIAROTg/quadlet-nix";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix"; #/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-unstable"; # WARNING: This may break things as stylix's nixpkgs should match home-manager (stable)
    };

    vicinae = {
      url = "github:vicinaehq/vicinae";
      # need to follow nixpkgs-unstable
      # https://github.com/vicinaehq/vicinae/issues/907
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xremap.url = "github:xremap/nix-flake";
  };
}
