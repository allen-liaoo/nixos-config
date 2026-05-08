{ inputs, ... }:

{
  imports = [
    inputs.quadlet-nix.nixosModules.quadlet
  ];

  virtualisation.quadlet = {
    enable = true;
    autoEscape = true;
    autoUpdate = {
      enable = true;
      calendar = "Mon *-*-* 00:00:00"; # every week
    };
  };
}
