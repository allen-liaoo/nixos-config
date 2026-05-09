{
  description = "NixOS Multi-Host & Multi-User Configuration";

  outputs =
    inputs:
    let
      lib = inputs.nixpkgs.lib;
      mkPkgs =
        pkgs: system:
        import pkgs {
          inherit system;
          config.allowUnfree = true;
        };

      alnLib = import ./lib { inherit lib; };
      inventory = import ./inventory { inherit lib alnLib; };
      mkCtx = ctx: import ./ctx.nix ({ inherit lib inventory; } // ctx);
    in
    {
      nixosConfigurations = lib.genAttrs inventory.nixosHostNames (
        hostName:
        let
          host = inventory.hosts.${hostName};
          system = host.system;
        in
        lib.nixosSystem {
          specialArgs = {
            inherit inputs alnLib inventory;
            ctx = mkCtx { inherit hostName; };
            pkgs-unstable = mkPkgs inputs.nixpkgs-unstable system;
          };
          system = system;
          modules = [
            ./host/${hostName}
            inputs.disko.nixosModules.disko
          ];
        }
      );

      homeConfigurations = lib.listToAttrs (
        map (
          { userName, hostName }:
          {
            name = "${userName}@${hostName}";
            value =
              let
                pkgs = mkPkgs inputs.nixpkgs system;
                system = inventory.hosts.${hostName}.system or inventory.systems.x86_linux;
              in
              inputs.home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                extraSpecialArgs = {
                  inherit inputs alnLib inventory;
                  ctx = mkCtx {
                    inherit hostName;
                    inherit userName;
                  };
                  pkgs-unstable = mkPkgs inputs.nixpkgs-unstable system;
                  pkgs-nur = inputs.nur.legacyPackages.${system};
                  pkgs-aln = import ./packages.nix { inherit pkgs; };
                };
                modules = [
                  ./home/${userName}
                ];
              };
          }
        ) inventory.userHostPairs
      );

      devShells = lib.genAttrs inventory.systems (import ./shell.nix { inherit inputs lib inventory; });
    };

  nixConfig = {
    extra-substituters = [ "https://vicinae.cachix.org" ];
    extra-trusted-public-keys = [ "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=" ];
  };

  inputs = {
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.quickshell.follows = "quickshell";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    glide = {
      url = "github:glide-browser/glide.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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

    matugen-themes = {
      url = "github:InioX/matugen-themes";
      flake = false;
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-your-shell = {
      url = "github:MercuryTechnologies/nix-your-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # my nixvim config
    nvimx = {
      url = "github:allen-liaoo/nvimx";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # dont set nixpkgs.follows or cachix cache misses
    vicinae.url = "github:vicinaehq/vicinae";

    vicinae-extensions.url = "github:vicinaehq/extensions";

    xremap.url = "github:xremap/nix-flake";
  };
}
