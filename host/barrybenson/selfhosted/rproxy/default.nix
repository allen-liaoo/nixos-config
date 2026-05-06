{ config, pkgs, alnLib, ... }:

let
  name = "rproxy";
  dataVolumeName = name + "_data";
  secretsDir = import ../secrets_dir.nix alnLib;
  blogGitUrl = "https://github.com/allen-liaoo/alsblog.git";
  blogCache = "/tmp/alsblog";
  domain = "allenl.me";
  cloudflare_secret_key = "cloudflare_token";
  cloudflare_secret_name = "rproxy_" + cloudflare_secret_key;
in
{
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) images volumes;
  in {
    containers.${name} = alnLib.mkContainer name {
      containerConfig = {
        image = images.${name}.ref;
  
        publishPorts = [ "80:80" "443:443" ];
        volumes = [
          "${./conf}:/etc/caddy:ro"
          "${blogCache}/build:/srv/alsblog:ro"
          "${volumes.${dataVolumeName}.ref}:/data:rw,U"
        ];

        environments = {
          DOMAIN = domain;
        };
        # secret passed in as environment variable for caddy dns provider
        environmentFiles = [ config.sops.templates.${cloudflare_secret_name}.path ];
      };
      unitConfig = {
        PartOf = [
          images.${name}.ref
          volumes.${dataVolumeName}.ref
        ];
      };
      serviceConfig = {
        # Check if blog files exists, if not, build it
        ExecStartPre = let
          buildBlog = pkgs.writeShellApplication {
            name = "build-alsblog";
            runtimeInputs = [ pkgs.git pkgs.hugo ];
            text = ''
              blog_build="${blogCache}/build"
              blog_build_tmp="${blogCache}/build.tmp"
              blog_repo="${blogCache}/repository"
              
              # Ensure cache directory exists
              mkdir -p "${blogCache}"

              # Keep repository and submodules up to date.
              if [ ! -d "$blog_repo/.git" ]; then
                git clone --recurse-submodules ${blogGitUrl} "$blog_repo"
              else
                git -C "$blog_repo" pull --ff-only
                git -C "$blog_repo" submodule update --init --recursive
              fi

              rm -rf "$blog_build_tmp"
              hugo --source="$blog_repo" --destination="$blog_build_tmp" --gc
              rm -rf "$blog_build"
              mv "$blog_build_tmp" "$blog_build"
            '';
          };
        in "${buildBlog}/bin/${buildBlog.name}";
      };
    };

    images.${name} = alnLib.mkImage {
      imageConfig.image = "ghcr.io/caddy-dns/cloudflare";
    };

    volumes.${dataVolumeName} = alnLib.mkVolume dataVolumeName {};
  };

  sops.secrets.${cloudflare_secret_name} = {
    sopsFile = secretsDir + "/rproxy.yaml";
    key = cloudflare_secret_key;
  };

  # build environment file for secret
  sops.templates.${cloudflare_secret_name}.content = "CF_API_TOKEN=${config.sops.placeholder.${cloudflare_secret_name}}";
}
