{ pkgs-nur, config, aln, ... }:

let
  symlinkHere = path: 
  path 
  |> aln.lib.outOfStoreRelToRoot config.home.homeDirectory 
  |> config.lib.file.mkOutOfStoreSymlink;
  theme_path = "Vieb/colors/custom_theme.css";
in
{
  home.packages = with pkgs-nur.repos.vieb-nix; [
    vieb
  ];

  xdg.configFile."Vieb/viebrc".text = ''
    source ./mainrc
    colorscheme custom_theme
  '';
  xdg.configFile."Vieb/mainrc".source = symlinkHere ./mainrc;
  xdg.configFile.${theme_path}.source = symlinkHere ./theme.css;
}

