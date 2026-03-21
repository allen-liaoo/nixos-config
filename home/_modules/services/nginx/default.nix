{ config, pkgs, aln, ... }:

let
  name = "nginx";
  volume_name = name + "_logs";
  pwdOutOfStore = aln.lib.outOfStoreRelToRoot config.home.homeDirectory ./.;
  cert_dir = "/var/tmp/cert";
  reload_cert_name = "${name}_reload_cert";
in
{
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) images volumes;
  in {
    containers.${name} = aln.lib.mkContainer name {
      containerConfig = {
        image = images.${name}.ref;
        exec = "nginx -g \"daemon off\";";
  
        publishPorts = [ "8080:8080" "8443:8443" ];
        userns = "host";
        volumes = let
          nginx_conf = config.lib.file.mkOutOfStoreSymlink (aln.lib.outOfStoreRelToRoot config.home.homeDirectory ./nginx.conf);
          sites = config.lib.file.mkOutOfStoreSymlink (aln.lib.outOfStoreRelToRoot config.home.homeDirectory ./sites);
          snippets = config.lib.file.mkOutOfStoreSymlink (aln.lib.outOfStoreRelToRoot config.home.homeDirectory ./snippets);
        in [
          "${nginx_conf}:/etc/nginx/nginx.conf:ro"
          "${sites}:/etc/nginx/sites:ro"
          "${snippets}:/etc/nginx/snippets:ro"
          "${cert_dir}:/etc/letsencrypt:ro"
          "${pwdOutOfStore}/blog_build:/usr/share/nginx/blog:ro"
          "${volumes.${volume_name}.ref}:/var/logs/nginx:rw"
        ];
  
        healthCmd = "service nginx status || exit 1";
        healthInterval = "1m";
        healthStartPeriod = "1m";
      };
      serviceConfig = {
        # Check if blog files exists, if not, build it
        ExecStartPre = let
          buildBlog = pkgs.writeShellApplication {
            name = "build-alsblog";
            runtimeInputs = [ pkgs.git pkgs.hugo ];
            text = ''
              if [ ! -d ${pwdOutOfStore}/blog_build ]; then
                git -C ${pwdOutOfStore}/blog pull
                hugo --source=${pwdOutOfStore}/blog --destination=${pwdOutOfStore}/blog_build --gc
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

    volumes.${volume_name} = aln.lib.mkVolume name {};
  };

  # Reload ssl cert
  systemd.user.timers.${reload_cert_name} = {
    Unit = {
      Description = "Reload nginx ssl certificate (every month)";
      Requires = "${reload_cert_name}.service";
    };
    Timer = {
      # Run on the first day of every month at 2:00 AM
      OnCalendar = "*-*-01 02:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.${reload_cert_name} = {
    Unit = {
      Description = "Reload nginx ssl certificate";
      After = "network-online.target";
      Wants = "network-online.target";
    };

    Service = {
      Type = "oneshot";
      ExecStart = let 
        domain = "allenl.me";
        email = "wcliaw610@gmail.com";
        obcrt = pkgs.writeShellApplication {
          name = "obtain-cert";
          runtimeInputs = [ pkgs.coreutils pkgs.acme-sh ];
          text = ''
            CF_Account_ID=$(cat ${config.sops.secrets.nginx_cloudflare_account_id.path})
            CF_Token=$(cat ${config.sops.secrets.nginx_cloudflare_token.path})

            # Ensure paths exist (not sure why acme.sh doesn't do this)
            mkdir -p ${cert_dir}/${domain}
            mkdir -p ${config.home.homeDirectory}/.acme.sh/${domain}

            # Obtain cert by DNS challenge using Cloudflare API
            CF_Account_ID=$CF_Account_ID CF_Token=$CF_Token \
            acme.sh --issue -d ${domain} -d '*.${domain}' \
                    --dns dns_cf \
                    --home ${config.home.homeDirectory}/.acme.sh \
                    --force

            # Copy certificate obtained (stored under user home) in nginx expected path
            acme.sh --install-cert -d ${domain} -d '*.${domain}' \
                    --home ${config.home.homeDirectory}/.acme.sh \
                    --key-file       ${cert_dir}/privkey.pem \
                    --fullchain-file ${cert_dir}/fullchain.pem \
                    --ecc
                    '';
            # without --home in both locations, we cant centralize where acme.sh stores and manages certs internally, so copy cert would fail
            # without --ecc, acme.sh cant find keys to install

        };
      in "${obcrt}/bin/${obcrt.name}";
      ExecStartPost = "systemctl --user restart ${name}.service";
    };
  };

  sops.secrets = {
    "nginx_cloudflare_account_id" = {
      mode = "0400";
      key = "nginx/cloudflare_account_id";
    };
    "nginx_cloudflare_token" = {
      mode = "0400";
      key = "nginx/cloudflare_token";
    };
  };
}
