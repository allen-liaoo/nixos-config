{
  inputs,
  alnLib,
  ...
}:

{
  imports = alnLib.importExcept (alnLib.listDirFiles ./.) [ "players.nix"] ++ alnLib.listSubdirs ./. ++ [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
  ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = false;
  };
}
# For declaring mods, see scripts/modrinth_prefetch.sh
