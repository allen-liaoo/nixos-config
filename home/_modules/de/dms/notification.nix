{
  programs.dank-material-shell.settings = {
    notificationRules = [
      {
        pattern = "Spotify";
        enabled = true;
        field = "appName";
        matchType = "contains";
        action = "ignore";
        urgency = "default";
      }
    ];
  };
}
