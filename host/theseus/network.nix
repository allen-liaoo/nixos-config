{ lib, config, aln, ... }:

let
  # NM connections/profiles
  connections = [ "hotspot_a16n" "wifi_eduroam" ];
in
{
  networking.networkmanager = {
    logLevel = "INFO";
    ensureProfiles = {
      # Below profiles are generated as .nmconnection files in /run/NetworkManager/system-connections (or /etc/NetworkManager/system-connections?)
      # Reference: https://networkmanager.dev/docs/api/latest/nm-settings-keyfile.html
      # NM setting reference: https://networkmanager.dev/docs/api/latest/nm-settings-nmcli.html
      # Note that .nmconnection files, and hence below attrSets, should use aliases:
      # 802-3-ethernet = ethernet
      # 802-11-wireless = wifi
      # 802-11-wireless-security = wifi-security
      # (nm setting key = .nmconnection key)
      # NOTE: trailing ":" is important in "list of ..." fields
      profiles = {
        # home server (DNS)
        wg_hs_dns = {
          connection = {
            id = "wg_hs_dns";
            type = "wireguard";
            interface-name = "wg_hs";
          };
          wireguard.private-key = "$WG_PRIVKEY";
          # TODO: Centralize keys and ips
          "wireguard-peer.CQvf4nOExaVkaiWpsxx0OctRU4N51xRYdKUoKteegQk=" = {
            endpoint = "74.208.158.11:51820"; 
            allowed-ips = "10.0.0.1/24;";
            persistent-keepalive = 25;
          };
          ipv4 = {
            address1 = "10.0.10.1/32";
            dns = "10.0.0.1;";
            method = "manual";
          };
          ipv6.method = "disabled";
        };
        # phone
        a16n = {
          connection = {
            id = "a16n";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "a16n";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$PASSWD_HOTSPOT_A16N";
          };
          ipv4.method = "auto";
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
        };
        eduroam = {
          connection = {
            id = "eduroam";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "eduroam";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-eap";
          };
          "802-1x" = {
            domain-suffix-match = "umn.edu";
            eap = "peap;"; # trailing ; is important!!
            identity = "liao0144@umn.edu";
            password = "$PASSWD_WIFI_EDUROAM";
            phase2-auth="mschapv2";
          };
          ipv4.method = "auto";
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
        };
      };
      # Fine to use env vars since the generated .nmconnection files are not in store
      environmentFiles = [ config.sops.templates."nm-secrets-env".path ];

      # NOTE: DO NOT RECOMMEND USING ensureProfiles.secrets (which uses nm-file-secret-agent)
      # as it is unreliable especially if nmcli is called with a different user than the one who runs the agent (root)
      # See: https://github.com/lilioid/nm-file-secret-agent/issues/4

      # To use it: set flags indicate field is agent owned (i.e. wifi-security.psk-flags = 1)
      # And it runs a systemd service "nm-file-secret-agent"
      # Note that in ensureProfiles.secrets, match names dont use aliases like above
    };
  };

  sops.secrets = (connections
    |> map (key: {
      "passwd_${key}" = {
        sopsFile = aln.lib.relToRoot "secrets/host/wifi_passwd.yaml";
        inherit key;
      };
    })
    |> lib.mergeAttrsList)
    // {
      theseus_wg_privkey = {
        sopsFile = aln.lib.relToRoot "secrets/host/theseus/common.yaml";
        key = "wg_privkey";
      };
    };

  sops.templates."nm-secrets-env".content = (connections 
    |> map (key: "PASSWD_${lib.toUpper key}=${config.sops.placeholder."passwd_${key}"}")
    |> lib.concatMapStrings (s: s + "\n"))
    + ''
      WG_PRIVKEY=${config.sops.placeholder.theseus_wg_privkey}
    '';
    
}
