{...}:
{
  # Import all files in a directory, excluding default.nix. Non-recurive
  importDir = (dir:
    let
      files = builtins.readDir dir;
      nixFiles = builtins.filter
        (name: name != "default.nix" && builtins.match ".*\\.nix" name != null)
        (builtins.attrNames files);
    in map (name: dir + "/${name}") nixFiles
  );
}
