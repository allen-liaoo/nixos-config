{ lib, ... }:

let
  rootPath = ../.; # project root path; resolves in nix store
in rec
{
  # use path relative to the root of this project
  # note that this will resolve to be a path within /nix/store
  # to refer to a path outside of /nix/store, use outOfStoreRelToRoot
  relToRoot = lib.path.append rootPath;

  # List all files in a directory, excluding "default.nix". Non-recurive
  listDirFiles = (dir:
    let
      files = builtins.readDir dir;
      nixFiles = builtins.filter
        (name: name != "default.nix" && builtins.match ".*\\.nix" name != null)
        (builtins.attrNames files);
    in map (name: dir + "/${name}") nixFiles);

  # List all immediate subdirectory of current directory
  listSubdirs = (dir:
    let
      entries = builtins.readDir dir;
      subdirs = builtins.filter
        (name: entries.${name} == "directory")
        (builtins.attrNames entries);
    in map (name: dir + "/${name}") subdirs);

  ## HOME MANAGER EXCLUSIVE ##

  # Directory of current repository relative to a user's $HOME
  # DO NOT USE DIRECTLY
  # We require that ALL INSTANCES OF THIS REPO ON NIXOS/NON-NIXOS MACHINES TO BE STORED IN THE BELOW PATH (one per user who manages hm/os on NixOS machines)
  # See outOfStoreRelToRoot for explanation
  NIX_CONFIG_REL_HOME = "/nix-config";

  # Returns the actual, out of store, path relative to the root of the repository
  # ONLY USE WITHIN HM
  # This is particularly useful for HM's mkOutOfStoreSymlink for managing dotfiles outside of the nix store (so one doesn't need to switch each time a change is made)
  # Due to how flakes work, one cannot use a relative path to refer to anything outside of the store
  # Because the repository is copied into the store and the relative path is resolved against it
  # Usage: when calling inside "modules/xyz/"
  #   outOfStoreRelToRoot config.home.HomeDirectory ./config.kdl
  # returns /home/hm_user/nix-config/modules/xyz/config.kdl
  # Note that ./config.kdl is a relative path that resolves in /nix/store, which is fine
  outOfStoreRelToRoot = (homeDir: relPath:
    let 
      flakePath = toString rootPath; 
      relPathStr = toString relPath;
    in
      assert lib.hasPrefix flakePath relPathStr;
      homeDir + NIX_CONFIG_REL_HOME + (lib.removePrefix flakePath relPathStr)); 
}
