{ lib, config, options, ... }:

let 
  systemsList = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];
  userType = lib.types.submodule ({config,...}: {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "nobody";
      };
      tags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      can = {
        deploy_nix_config = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };
    };
  });
in 
{
  options = {
    hosts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({config,...}: {
        options = {
          name   = lib.mkOption {
            type = lib.types.str;
          };
          system = lib.mkOption {
            type = lib.types.enum systemsList;
            default = "x86_64-linux";
          };
          kind = lib.mkOption {
            type = lib.types.enum [
              "server"
              "computer"
            ];
            description = "Categorized by function";
          };
          users = lib.mkOption {
            type    = lib.types.listOf userType;
            default = [];
          };
          tags = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };

          # derived / read-only
          os = lib.mkOption {
            type = lib.types.enum [
              "linux"
              "darwin"
            ];
            default = if lib.hasSuffix "-linux" config.system then "linux" else "darwin";
            readOnly = true;
          };

          is = {
            headless = lib.mkOption {
              type = lib.types.bool;
              default = config.kind == "server";
              readOnly = true;
            };
            gui = lib.mkOption {
              type = lib.types.bool;
              default = config.kind != "server";
              readOnly = true;
            };
            darwin = lib.mkOption {
              type = lib.types.bool;
              default = config.host.os == "darwin";
              readOnly = true;
            };
            linux = lib.mkOption {
              type = lib.types.bool;
              default = config.host.os == "linux";
              readOnly = true;
            };
          };
        };
      }));
    };

    users = lib.mkOption {
      type = lib.types.attrsOf userType;
    };

    # derived / read-only

    systemsList = lib.mkOption {
      type     = lib.types.listOf lib.types.str;
      default = systemsList;
      readOnly = true;
    };

    hostNames = lib.mkOption {
      type     = lib.types.listOf lib.types.str;
      default = builtins.attrNames config.hosts;
      readOnly = true;
    };

    userNames = lib.mkOption {
      type     = lib.types.listOf lib.types.str;
      default = builtins.attrNames config.users;
      readOnly = true;
    };

    userHostPairs = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          userName = lib.mkOption { type = lib.types.str; };
          hostName = lib.mkOption { type = lib.types.str; };
        };
      });
      default = lib.flatten (
        lib.mapAttrsToList (hostName: hostCfg:
          hostCfg.users
          |> map (user: user.name)
          |> map (userName: { inherit userName hostName; }) 
        ) config.hosts
      );
      readOnly = true;
    };
  };
}
