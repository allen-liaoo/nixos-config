{ lib, config, options, alnLib, ... }:

let 
  hostKinds = [
    "server"
    "laptop"
  ];
  oses = [
    "darwin" # unused
    "generic-linux"
    "nixos"
  ];
  systems = [
    "x86_64-linux"
  ];
  gpus = [
    "amd"
    "nvidia"
  ];
  hostTags = [
    "impermanent"
  ];
  userTags = [
    # Tags for users in nixos systems
    "system-user" # for normal users, ommit this # unused
    "linger" # unused
  ];
  userType = lib.types.submodule ({config,...}: {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "nobody";
      };
      groups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      tags = lib.mkOption {
        type = lib.types.listOf (lib.types.enum userTags);
        default = [ ];
      };
      hasTags = lib.mkOption {
        type = lib.types.functionTo lib.types.bool;
        default = tags:
          lib.all (tag: builtins.elem tag config.tags) tags;
        readOnly = true;
      };
      can = {
        deployNixConfig = lib.mkOption {
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
          kind = lib.mkOption {
            type = lib.types.enum hostKinds;
            description = "Categorized by function";
          };
          os = lib.mkOption {
            type = lib.types.enum oses;
          };
          system = lib.mkOption {
            type = lib.types.enum systems;
            default = "x86_64-linux";
          };
          gpu = lib.mkOption {
            type = lib.types.enum gpus;
          };
          users = lib.mkOption {
            type    = lib.types.listOf userType;
            default = [];
          };
          tags = lib.mkOption {
            type = lib.types.listOf (lib.types.enum hostTags);
            default = [ ];
          };
          hasTags = lib.mkOption {
            type = lib.types.functionTo lib.types.bool;
            default = tags:
              lib.all (tag: builtins.elem tag config.tags) tags;
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
          }
          // (lib.mergeAttrsList (map (kind: {
            ${kind} = lib.mkOption {
              type = lib.types.bool;
              default = config.kind == kind;
              readOnly = true;
            };
          }) hostKinds))
          // (lib.mergeAttrsList (map (os: {
            ${os} = lib.mkOption {
              type = lib.types.bool;
              default = config.os == os;
              readOnly = true;
            };
          }) oses))
          // (lib.mergeAttrsList (map (gpu: {
            ${gpu} = lib.mkOption {
              type = lib.types.bool;
              default = config.gpu == gpu;
              readOnly = true;
            };
          }) gpus));
        };
      }));
    };

    users = lib.mkOption {
      type = lib.types.attrsOf userType;
    };

    # derived / read-only

    systems = lib.mkOption {
      type     = lib.types.listOf lib.types.str;
      default = systems;
      readOnly = true;
    };

    hostNames = lib.mkOption {
      type     = lib.types.listOf lib.types.str;
      default = builtins.attrNames config.hosts;
      readOnly = true;
    };

    nixosHostNames = lib.mkOption {
      type     = lib.types.listOf lib.types.str;
      default = config.hosts |> lib.filterAttrs (_: h: h.is.nixos) |> builtins.attrNames;
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
