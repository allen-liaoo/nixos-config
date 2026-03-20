{ config, pkgs, aln, ... }:

let
  name = "nginx";
  volume_name = name + "_logs";
  cert_dir = "/var/tmp/cert";
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
        volumes = [
          "${./nginx.conf}:/etc/nginx/nginx.conf:ro"
          "${./sites}:/etc/nginx/sites:ro"
          "${./snippets}:/etc/nginx/snippets:ro"
          "${cert_dir}:/etc/letsencrypt:ro"
          "${volumes.${volume_name}.ref}:/var/logs/nginx:rw"
        ];
  
        healthCmd = "service nginx status || exit 1";
        healthInterval = "1m";
        healthStartPeriod = "1m";
      };
    };

    images.${name} = aln.lib.mkImage name {
      imageConfig.image = "docker.io/library/nginx";
    };

    volumes.${volume_name} = aln.lib.mkVolume name {};
  };

  # systemd service and timer to reload ssl cert
  systemd.user.services."${name}_reload_cert" = {
    Unit = {
      Description = "Reload nginx ssl certificate";
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
            mkdir -p ${cert_dir}/${domain}
            mkdir -p ${config.home.homeDirectory}/.acme.sh/${domain}

            CF_Account_ID=$CF_Account_ID CF_Token=$CF_Token \
            acme.sh --issue -d ${domain} -d '*.${domain}' \
                    --dns dns_cf \
                    --home ${config.home.homeDirectory}/.acme.sh \
                    --force
            acme.sh --install-cert -d ${domain} -d '*.${domain}' \
                    --home ${config.home.homeDirectory}/.acme.sh \
                    --key-file       ${cert_dir}/privkey.pem \
                    --fullchain-file ${cert_dir}/fullchain.pem \
                    --ecc     # without this, acme.sh cant find keys to install
          '';
        };
      in "${obcrt}/bin/${obcrt.name}";
      ExecStartPost = "systemctl --user restart ${name}.service";
    };
  };

  sops.secrets = {
    "nginx_cloudflare_account_id" = {
      sopsFile = aln.lib.relToRoot "secrets/user/${config.home.username}.yaml";
      mode = "0400";
      key = "nginx/cloudflare_account_id";
    };
    "nginx_cloudflare_token" = {
      sopsFile = aln.lib.relToRoot "secrets/user/${config.home.username}.yaml";
      mode = "0400";
      key = "nginx/cloudflare_token";
    };
  };
}
