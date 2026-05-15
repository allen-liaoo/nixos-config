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
    managementSystem = {
      tmux.enable = false;
      systemd-socket.enable = true;
    };
  };

  aln.impermanence.dirs = [
    "/srv/minecraft"
  ];
}
# For declaring mods, see scripts/modrinth_prefetch.sh
