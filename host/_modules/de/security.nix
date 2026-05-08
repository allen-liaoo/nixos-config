{ pkgs, ... }:

{
  # required for gnome keyring
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  security.pam.services.polkit-1.fprintAuth = true;
  security.polkit.extraConfig = ''
    /* NetworkManager: dont trigger polkit prompt for sudoers */
    polkit.addRule(function(action, subject) {
      if (
        action.id.indexOf("org.freedesktop.NetworkManager.") === 0 &&
        subject.isInGroup("wheel")
      ) {
        return polkit.Result.YES;
      }
    });
  '';

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
