{ lib, config, pkgs, inputs, ... }@args:

{
  imports = [
    (import ./firefox/extendedFirefoxModule { 
      modulePath = [ "programs" "firefox" ];
    })
  ];

  programs.firefox = import ./firefox args;
}
