{ lib, pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  environment.systemPackages = with pkgs; [ bluez ];

  boot.kernelModules = [ "bnep" ]; # bluetooth tethering
}
