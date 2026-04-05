{ lib, config, aln, ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./config.json); # fastfetch default without ip
  };
}
