{
  pkgs,
  ...
}:

let
  prismlauncher-wrapped = pkgs.symlinkJoin {
    name = "prismlauncher-wrapped";
    paths = [ pkgs.prismlauncher ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = with pkgs; ''
      wrapProgram $out/bin/prismlauncher \
        --set XDG_DATA_DIRS "${glib.getSchemaPath gsettings-desktop-schemas}:${gtk3}/share/gsettings-schemas/${gtk3.name}"
    '';
  };
in
{
  home.packages = with pkgs; [
    prismlauncher-wrapped
  ];
}
