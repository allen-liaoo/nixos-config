{
  inputs,
  aln,
  ...
}:

{
  imports = aln.listDirFiles ./. ++ aln.listSubDirs ./. ++ [
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
