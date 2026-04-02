# OpenGL and GPU related things often break on non-nixos systems
# This fixes it without requiring sudo privileges
# https://nix-community.github.io/home-manager/index.xhtml#sec-usage-gpu-nosudo
# https://github.com/nix-community/nixGL
{ lib, inputs, pkgs, aln, ... }:

lib.optionalAttrs aln.ctx.host.is.generic-linux {
  targets.genericLinux.nixGL = {
    packages = inputs.nixgl.packages.${pkgs.stdenv.hostPlatform.system};
    defaultWrapper = 
      if aln.ctx.host.is.amd then "mesa"
      else if aln.ctx.host.is.nvidia then "nvidia"
      else ""; # ERROR
  };
  # One can then wrap GUI programs with
  # config.lib.nixGL.wrap <pkg>
  # this is a no-op on nixos systems, so we always wrap GUI programs with this if an issue is encountered
}

