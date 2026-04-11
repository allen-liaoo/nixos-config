# In .profiles.<name>.settings
# TODO: Can't seem to disable home page shortcuts
{
  "app.normandy.api_url" = "";
  "app.normandy.enabled" = false; # https://mozilla.github.io/normandy/
  "app.shield.optoutstudies.enabled" = false;
  "beacon.enabled" = false; # Disable "beacon" asynchronous HTTP transfers (used for analytics)
  "browser.aboutConfig.showWarning" = false;
  "browser.contentblocking.report.hide_vpn_banner" = true;
  "browser.contentblocking.report.vpn.enabled" = false;
  "browser.contentblocking.report.show_mobile_app" = false;
  "browser.dataFeatureRecommendations.enabled" = false;
  "browser.tabs.insertAfterCurrent" = true;
  "browser.newtabpage.activity-stream.default.sites" = "";
  "browser.newtabpage.activity-stream.feeds.section.topstories.options" = "{\"hidden\":true}";
  "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
  "browser.newtabpage.activity-stream.feeds.smartshortcutsfeed" = false;
  "browser.newtabpage.activity-stream.showSearch" = false;
  "browser.newtabpage.activity-stream.showSponsored" = false;
  "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
  "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
  "browser.newtabpage.activity-stream.showWeather" = false;
  # shortcuts; have to fill 8 (a row) or firefox will fill them :(
  "browser.newtabpage.pinned" = [
    #{ url = "about:blank?1"; }
    #{ url = "about:blank?2"; }
    #{ url = "about:blank?3"; }
    #{ url = "about:blank?4"; }
    #{ url = "about:blank?4"; }
    #{ url = "about:blank?4"; }
    #{ url = "about:blank?4"; }
    #{ url = "about:blank?4"; }
  ];
  "browser.promo.focus.enabled" = false;
  "browser.startup.homepage_override.mstone" = "ignore";
  "browser.startup.homepage" = "about:blank";
  "browser.uitour.enabled" = false;
  "browser.urlbar.showSearchSuggestionsFirst" = false;
  "browser.urlbar.suggest.realtimeOptIn" = false;
  "browser.urlbar.suggest.sports" = false;
  "browser.urlbar.suggest.topsites" = false;
  "browser.urlbar.suggest.trending" = false;
  "browser.urlbar.suggest.weather" = false;
  "browser.urlbar.suggest.yelp" = false;
  "browser.urlbar.suggest.yelpRealtime" = false;
  "browser.vpn_promo.enabled" = false;
  "devtools.browserconsole.filter.css" = true;
  "devtools.chrome.enabled" = true;
  "devtools.debugger.remote-enabled" = true;
  "extensions.htmlaboutaddons.recommendations.enabled" = false;
  "signon.rememberSignons" = false; # dont prompt to remember passwords
  "startup.homepage_override_url" = "about:home";
  "startup.homepage_welcome_url" = "about:home";
  "startup.homepage_welcome_url.additional" = "";
  "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # Allow userCrome.css
}
