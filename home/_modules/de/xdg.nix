{
  lib,
  pkgs,
  config,
  ctx,
  ...
}:

let
  browser = "firefox.desktop";
  docViewer = "sioyek.desktop";
  vidViewer = "mpv.desktop";
  imgViewer = "org.gnome.Loupe.desktop";
  fileExplorer = "org.gnome.Nautilus.desktop";
  textEditor = "nvim.desktop";

  mimeTypes =
    prefix: suffixes: app:
    suffixes
    |> map (s: {
      ${prefix + "/" + s} = app;
    })
    |> lib.mergeAttrsList;

  browserMimes = mimeTypes "x-scheme-handler" [
    "about"
    "http"
    "https"
    "ftp"
    "irc"
    "ircs"
    "tel"
    "sms"
    "geo"
    "bitcoin"
    "slack"
  ];
  imageMimes = mimeTypes "image" [
    "avif"
    "bmp"
    "gif"
    "heic"
    "ico"
    "jpeg"
    "png"
    "svg+xml"
    "tiff"
    "webp"
  ];
  videoMimes = mimeTypes "video" [
    "3gp"
    "3gpp"
    "avi"
    "m4v"
    "mkv"
    "mov"
    "mp2t"
    "mp4"
    "mpeg"
    "ogg"
    "webm"
    "wmv"
  ];
  audioMimes = mimeTypes "audio" [
    "mpeg"
    "mp3"
    "wav"
    "ogg"
    "opus"
    "flac"
    "aac"
    "m4a"
    "aiff"
    "wma"
    "amr"
    "alac"
    "mid"
    "midi"
    "x-midi"
    "x-wav"
    "x-aiff"
  ];
  textMimes = mimeTypes "text" [
    "plain"
    "csv"
    "tsv"
    "html"
    "xml"
    "xhtml+xml"
    "json"
    "yaml"
    "x-yaml"
    "toml"
    "markdown"
    "x-markdown"
    "rfc822"
    "rtf"
    "sh"
    "x-sh"
  ];
  codeMimes = mimeTypes "text" [ ]; # TODO
in
{
  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications =
        browserMimes browser
        // imageMimes imgViewer
        // videoMimes vidViewer
        //
          #audioMimes "" // #TODO
          textMimes textEditor
        // codeMimes textEditor // #TODO
          {
            "application/pdf" = docViewer;
            "x-scheme-handler/mailto" = "thunderbird.desktop";
            "x-scheme-handler/magnet" = "qbittorrent.desktop";
            "x-scheme-handler/spotify" = "spotify.desktop";
            "x-scheme-handler/discord" = "vesktop.desktop";
          };
    };

    terminal-exec = {
      enable = true;
      settings.default = [ "Alacritty.desktop" ];
    };

    portal = {
      enable = true;
      config.niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Settings" = [ "gnome" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
      xdgOpenUsePortal = true;
    };
  }
  // lib.optionalAttrs (!ctx.host.is.server) {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };
}
