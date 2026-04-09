# id is name@dev or {uuid}
# name is name in mozilla store (if not 3rd party)
[
  { # Bypass paywall clean
    id = "magnolia@12.34";
    name = ""; # third party, no name
  }
  {
    id = "addon@darkreader.org";
    name = "darkreader";
  }
  {
    id = "uBlock0@raymondhill.net";
    name = "ublock-origin";
  }
  {
    id = "{d7742d87-e61d-4b78-b8a1-b469842139fa}";
    name = "vimium-ff";
  }
  {
    id = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
    name = "bitwarden-password-manager";
  }
  { # nord theme
    id = "{48899556-1d2f-4de1-8e60-0746fc84c23e}";
    name = "nord-milav";
  }
]

# To find extension ids/uuids, go to about:debugging#/runtime/this-firefox
# To find extension name, check extension url in webstore, which should be something like
# https://addons.mozilla.org/en-US/firefox/addon/ADDON_NAME/
