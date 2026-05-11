{ modulePath, profile }:

{
  lib,
  ...
}:

# let
  # extns = map
  #   (ext:
  #     (builtins.replaceStrings
  #       [ "{" "}" "@" "." ] # replace special chars with underscore
  #       [ "_" "_" "_" "_" ]
  #       ext.id) + "-browser-action") # i.e. ublock0_raymondhill_net-browser-action
  #   (import ./extensions_meta.nix);
# in
lib.setAttrByPath modulePath {
  profiles.${profile}.settings = {
    "browser.uiCustomization.state" = {
      placements = {
        nav-bar = [
          "back-button"
          "forward-button"
          "vertical-spacer"
          "stop-reload-button"
          "urlbar-container"
          "unified-extensions-button"
          # TODO: ublock will automatically be added to nav bar; cant disable
        ];
        widget-overflow-fixed-list = [
          "history-panelmenu"
          "downloads-button"
          "preferences-button"
          "developer-button"
          "fxa-toolbar-menu-button"
        ];
        # unified-extensions-area = extns ++ [
        #   #"firefoxcolor_mozilla_com-browser-action" # implicit but doesn't seem necessary
        # ]; # extension dropdown
        toolbar-menubar = [
          "menubar-items"
        ];
        TabsToolbar = [
          "tabbrowser-tabs"
          "new-tab-button"
          "alltabs-button"
        ];
        vertical-tabs = [ ];
        PersonalToolbar = [
          "personal-bookmarks"
        ];
      };
      seen = [
        #"developer-button"
        #"screenshot-button"
        #"firefoxcolor_mozilla_com-browser-action"
      ]; # ++ extns;
      DirtyAreaCache = [
        #"unified-extensions-area"
        #"TabsToolbar"
        #"widget-overflow-fixed-list"
        #"nav-bar"
        #"toolbar-menubar"
        #"vertical-tabs"
        #"PersonalToolbar"
      ];
      # Need to set these high enough to override default (figured out thru testing)
      currentVersion = 23;
      newElementCount = 12;
    };
  };
}

# To get previous customization state:
# cat ~/.mozilla/firefox/PROFILE/prefs.js | grep uiCustomization.state | sed -E 's/^user_pref\("[^"]+", "(.*)"\);$/\1/' | sed 's/\\//g' | jq .
