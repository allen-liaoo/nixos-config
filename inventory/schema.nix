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
  ];
  hostUserTags = [
    # Tags for users in nixos systems
    "system-user" # for normal users, ommit this # unused
    "linger" # unused
  ];
  groups = [
    "wheel"
    "input"
  ];
  # Type of users
  userOpts = with lib.types; ({config,...}: {
    options = {
      name = lib.mkOption {
        type = str;
        default = "nobody";
      };
      tags = lib.mkOption {
        type = listOf (enum userTags);
        default = [ ];
      };
    };
  });
  # Type of user tied to specific host
  hostUserOpts = with lib.types; ({config,...}@args: {
    options = (userOpts args).options // {
      can = {
        deployNixConfig = lib.mkOption {
          type = bool;
          default = false;
        };
      };
      utags = lib.mkOption {
        type = listOf (enum (userTags ++ hostUserTags));
        default = [ ];
      };
      hasTag = lib.mergeAttrsList (map (tag: {
        ${tag} = lib.mkOption {
          type = bool;
          default = builtins.elem tag (config.tags ++ config.utags);
          readOnly = true;
        };
      }) (userTags ++ hostUserTags));
      groups = lib.mkOption {
        type = listOf (enum groups);
        default = [ ];
      };
      inGroup = lib.mergeAttrsList (map (group: {
        ${group} = lib.mkOption {
          type = bool;
          default = builtins.elem group config.groups;
          readOnly = true;
        };
      }) groups);
    };
  });
in with lib.types; {
  options = {
    hosts = lib.mkOption {
      type = attrsOf (submodule ({config,...}: {
        options = {
          name   = lib.mkOption {
            type = str;
          };
          kind = lib.mkOption {
            type = enum hostKinds;
            description = "Categorized by function";
          };
          os = lib.mkOption {
            type = enum oses;
          };
          system = lib.mkOption {
            type = enum systems;
            default = "x86_64-linux";
          };
          gpu = lib.mkOption {
            type = enum gpus;
          };
          users = lib.mkOption {
            type = listOf (submodule hostUserOpts);
            default = [];
          };
          tags = lib.mkOption {
            type = listOf (enum hostTags);
            default = [ ];
          };
          hasTag = lib.mergeAttrsList (map (tag: {
            ${tag} = lib.mkOption {
              type = bool;
              default = builtins.elem tag config.tags;
              readOnly = true;
            };
          }) hostTags);
          equals = lib.mkOption {
            type = functionTo bool;
            default = host: host.name == config.name;
            readOnly = true;
          };
          is = {
            headless = lib.mkOption {
              type = bool;
              default = config.kind == "server";
              readOnly = true;
            };
            gui = lib.mkOption {
              type = bool;
              default = config.kind != "server";
              readOnly = true;
            };
          } //
          (lib.mergeAttrsList (map (kind: {
            ${kind} = lib.mkOption {
              type = bool;
              default = config.kind == kind;
              readOnly = true;
            };
          }) hostKinds)) //
          (lib.mergeAttrsList (map (os: {
            ${os} = lib.mkOption {
              type = bool;
              default = config.os == os;
              readOnly = true;
            };
          }) oses)) //
          (lib.mergeAttrsList (map (gpu: {
            ${gpu} = lib.mkOption {
              type = bool;
              default = config.gpu == gpu;
              readOnly = true;
            };
          }) gpus));
        };
      }));
    };

    users = lib.mkOption {
      type = attrsOf (submodule userOpts);
    };

    # derived / read-only

    systems = lib.mkOption {
      type     = listOf str;
      default = systems;
      readOnly = true;
    };

    hostNames = lib.mkOption {
      type     = listOf str;
      default = builtins.attrNames config.hosts;
      readOnly = true;
    };

    nixosHostNames = lib.mkOption {
      type     = listOf str;
      default = config.hosts |> lib.filterAttrs (_: h: h.is.nixos) |> builtins.attrNames;
      readOnly = true;
    };

    userNames = lib.mkOption {
      type     = listOf str;
      default = builtins.attrNames config.users;
      readOnly = true;
    };

    userHostPairs = lib.mkOption {
      type = listOf (submodule {
        options = {
          userName = lib.mkOption { type = str; };
          hostName = lib.mkOption { type = str; };
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
