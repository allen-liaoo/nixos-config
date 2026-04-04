{ lib, ... }:

{
  programs.firefox.policies = {
    AutofillAddressEnabled = true;
    AutofillCreditCardEnabled = true;

    DisableFirefoxScreenshots = true;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DisableProfileImport = true;
    DisableTelemetry = true;
    DontCheckDefaultBrowser = true;
    FirefoxSuggest = {
      WebSuggestions = false;
      SponsoredSuggestions = false;
      ImproveSuggest = false;
      Locked = true;
    };
    GenerativeAI = {
      Enabled = false;
      Chatbot = false;
      LinkPreviews = false;
      TabGroups = false;
      Locked = true;
    };

    HardwareAcceleration = true;

    NoDefaltBookmarks = true;
    UserMessaging = {
      ExtensionRecommendations = false;
      FeatureRecommendations = false;
      UrlbarInterventions = false; # firefox specific suggestions
      SkipOnboarding = true;
      MoreFromMozilla = false;
      FirefoxLabs = false;
    };
  };
}
