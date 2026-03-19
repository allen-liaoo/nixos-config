{ config, aln, ... }:

{
  virtualisation.quadlet = let 
    name = "nginx";
    inherit (config.virtualisation.quadlet) images;
  in {
    containers."${name}" = aln.lib.mkContainer name {
      containerConfig = {
        image = images."${name}".ref;
        exec = "nginx -g \"daemon off\";";
  
        publishPorts = [ "8080:8080" "8443:8443" ];

        volumes = [
          ("" + ./nginx.conf + ":/etc/nginx/nginx.conf:ro")
          ("" + ./sites + ":/etc/nginx/sites:ro")
          ("" + ./snippets + ":/etc/nginx/snippets:ro")
          # TODO: letsencrypt use podman cp to /etc/letsencrypt/
          "nginx_logs:/var/logs/nginx:rw"
        ];
  
        healthCmd = "service nginx status || exit 1";
        healthInterval = "1m";
        healthStartPeriod = "1m";
      };
    };

    images."${name}" = aln.lib.mkImage name {
      imageConfig.image = "docker.io/library/nginx";
    };
  };

  # systemd service and timer to reload ssl cert
  systemd.user.services."nginx_reload_cert" = {
    Unit = {
      Description="Reload nginx ssl certificate";
      After="network-online.target";
      Wants="network-online.target";
    };
  };
}
