# DISABLED; SWITCHED TO CADDY
# reload cert and friends not working
{ config, pkgs, lib, aln, ... }:

let
  name = "nginx";
  bootstrapCertName = "${name}_bootstrap_cert";
  volumeName = name + "_logs";
  certsVolumeName = name + "_certs";
  certsVolumeUnit = "${certsVolumeName}-volume.service";
  blogGitUrl = "https://github.com/allen-liaoo/alsblog.git";
  blogCache = "/tmp/asblog";
  acmeShDir = "/var/lib/acme.sh";
  certDir = "/var/lib/nginx-certs";
  reloadCertName = "${name}_reload_cert";
  domain = "allenl.me";
  email = "wcliaw610@gmail.com";
in lib.optionalAttrs false {
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) images volumes;
  in {
    containers.${name} = aln.lib.mkContainer name {
      containerConfig = {
        image = images.${name}.ref;
        exec = "nginx -g \"daemon off\";";
  
        publishPorts = [ "8080:8080" "8443:8443" ];
        userns = "auto";
        volumes = [
          "${./nginx.conf}:/etc/nginx/nginx.conf:ro"
          "${./sites}:/etc/nginx/sites:ro"
          "${./snippets}:/etc/nginx/snippets:ro"
          "${volumes.${certsVolumeName}.ref}:/etc/letsencrypt:ro"
          "${blogCache}/build:/usr/share/nginx/blog:ro"
          "${volumes.${volumeName}.ref}:/var/logs/nginx:rw"
        ];
  
        healthCmd = "service nginx status || exit 1";
        healthInterval = "1m";
        healthStartPeriod = "1m";
      };
      unitConfig = {
        Requires = [ "${bootstrapCertName}.service" ];
        After = [ "${bootstrapCertName}.service" ];
      };
      serviceConfig = {
        # Check if blog files exists, if not, build it
        ExecStartPre = let
          buildBlog = pkgs.writeShellApplication {
            name = "build-alsblog";
            runtimeInputs = [ pkgs.git pkgs.hugo ];
            text = ''
              blog_build="${blogCache}/build"
              blog_repo="${blogCache}/repository"
              
              # Ensure cache directory exists
              mkdir -p "${blogCache}"
              
              # Check if build directory exists
              if [ ! -d "$blog_build" ]; then
                # Check if repository exists
                if [ ! -d "$blog_repo" ]; then
                  # Clone the repository
                  git clone ${blogGitUrl} "$blog_repo"
                else
                  # Pull if it exists
                  git -C "$blog_repo" pull
                fi
                
                # Build the blog
                hugo --source="$blog_repo" --destination="$blog_build" --gc
              fi
            '';
          };
        in "${buildBlog}/bin/${buildBlog.name}";
        # Check nginx config then reload
        ExecReload = "podman exec nginx sh -c 'nginx -t && nginx -s reload'";
      };
    };

    images.${name} = aln.lib.mkImage name {
      imageConfig.image = "docker.io/library/nginx";
    };

    volumes.${volumeName} = aln.lib.mkVolume name {};
    volumes.${certsVolumeName} = aln.lib.mkVolume (name + "_certs") {};
  };

  # Reload ssl cert
  systemd.timers.${reloadCertName} = {
    description = "Reload nginx ssl certificate (every month)";
    requires = [ "${reloadCertName}.service" ];
    timerConfig = {
      # Run on the first day of every month at 2:00 AM
      OnCalendar = "*-*-01 02:00:00";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };

  systemd.services.${reloadCertName} = {
    description = "Reload nginx ssl certificate";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      ExecStart = let 
        obcrt = pkgs.writeShellApplication {
          name = "obtain-cert";
          runtimeInputs = [ pkgs.coreutils pkgs.acme-sh ];
          text = ''
            CF_Account_ID=$(cat ${config.sops.secrets.nginx_cloudflare_account_id.path})
            CF_Token=$(cat ${config.sops.secrets.nginx_cloudflare_token.path})

            # Ensure paths exist (Not sure why acme.sh doesn't do this)
            mkdir -p ${certDir}
            mkdir -p ${acmeShDir}/${domain}

            # Ensure acme account exists and use Let's Encrypt for non-interactive runs
            acme.sh --home ${acmeShDir} --set-default-ca --server letsencrypt
            acme.sh --home ${acmeShDir} --register-account -m ${email}

            # Obtain cert by DNS challenge using Cloudflare API
            CF_Account_ID=$CF_Account_ID CF_Token=$CF_Token \
            acme.sh --issue -d ${domain} -d '*.${domain}' \
                    --dns dns_cf \
                    --home ${acmeShDir} \
                    --force

            # Install certificate to host directory
            acme.sh --install-cert -d ${domain} -d '*.${domain}' \
                    --home ${acmeShDir} \
                    --key-file       ${certDir}/privkey.pem \
                    --fullchain-file ${certDir}/fullchain.pem \
                    --ecc
          '';
          # without --home in both locations, we cant centralize where acme.sh stores and manages certs internally, so copy cert would fail
          # without --ecc, acme.sh cant find keys to install
        };
      in "${obcrt}/bin/${obcrt.name}";
      ExecStartPost = [
        "systemctl restart ${name}.service"
      ];
    };
  };

  # Check if certs exist, if not, run the service to obtain certs before starting nginx 
  systemd.services.${bootstrapCertName} = {
    description = "Bootstrap nginx ssl cert files if missing";
    after = [ "network-online.target" certsVolumeUnit ];
    requires = [ certsVolumeUnit ];
    wants = [ "network-online.target" ];
    wantedBy = [ certsVolumeUnit ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = let
        bootstrap = pkgs.writeShellApplication {
          name = "bootstrap-nginx-cert";
          runtimeInputs = [ pkgs.podman ];
          text = ''
            cert_volume_path=$(podman volume inspect ${certsVolumeName}-volume --format '{{ .Mountpoint }}')

            if test -f "$cert_volume_path/privkey.pem" \
              && test -f "$cert_volume_path/fullchain.pem"; then
              exit 0
            fi

            systemctl start ${reloadCertName}.service
          '';
        };
      in "${bootstrap}/bin/${bootstrap.name}";
    };
  };

  sops.secrets = lib.listToAttrs (map (secret: {
    name = "nginx_${secret}";
    value = {
      sopsFile = aln.lib.relToRoot "secrets/services/nginx.yaml";
      mode = "0400";
      key = "nginx/${secret}";
    };
  }) [ "cloudflare_account_id" "cloudflare_token" ]);
}
