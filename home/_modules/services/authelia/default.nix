{ config, lib, aln, ... }:

let
  name = "authelia";
  db_name = name + "_db";
  pod_name = name + "-pod";
  logs_volume_name = name + "_logs";
in
{
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) containers images pods volumes;
  in {
    # authelia container
    containers.${name} = aln.lib.mkContainer name {
      containerConfig = {
        image = images.${name}.ref;
        pod = pods.${pod_name}.ref;
        startWithPod = true;
        volumes = let
          authelia_conf = config.lib.file.mkOutOfStoreSymlink (aln.lib.outOfStoreRelToRoot config.home.homeDirectory ./configuration.yml);
          users_db = config.lib.file.mkOutOfStoreSymlink (aln.lib.outOfStoreRelToRoot config.home.homeDirectory ./users_database.yml);
        in [
          #"${authelia_conf}:/config/configuration.yml:ro"
          #"${users_db}:/config/users_database.yml:ro"
          "${volumes.${logs_volume_name}.ref}:/logs:rw"

          # SOPS-managed file secrets mounted directly for Authelia template function.
          "${config.sops.secrets.authelia_session_secret.path}:/run/secrets/session_secret:ro"
          "${config.sops.secrets.authelia_storage_encryption_key.path}:/run/secrets/storage_encryption_key:ro"
          "${config.sops.secrets.authelia_postgres_password.path}:/run/secrets/postgres_password:ro"
          "${config.sops.secrets.authelia_oidc_jwk_key_priv.path}:/run/secrets/oidc_jwk_key_priv:ro"
        ];
        environments = {
          X_AUTHELIA_CONFIG = "/config/configuration.yml";
          X_AUTHELIA_CONFIG_FILTERS = "template";
        };
        healthCmd = "/app/healthcheck.sh";
        healthInterval = "5m";
        healthStartPeriod = "5s";
      };
      serviceConfig = {
        Requires = containers.${db_name}.ref;
        After = containers.${db_name}.ref;
      };
    };

    # authelia database container
    containers.${db_name} = aln.lib.mkContainer db_name {
      containerConfig = {
        image = images.${db_name}.ref;
        pod = pods.${pod_name}.ref;
        startWithPod = true;
        volumes = [
          "${volumes.${db_name}.ref}:/var/lib/postgresql/18/data:rw"
        ];
        environments = {
          POSTGRES_DB = "authelia";
          POSTGRES_USER = "authelia";
        };
        environmentFiles = [ config.sops.templates.authelia_db_env.path ];
      };
    };

    pods.${pod_name} = aln.lib.mkPod pod_name {
      podConfig = {
        publishPorts = [ "9080:80" ];
      };
    };

    images.${name} = aln.lib.mkImage name {
      imageConfig.image = "docker.io/authelia/authelia:latest";
    };

    images.${db_name} = aln.lib.mkImage db_name {
      imageConfig.image = "docker.io/library/postgres:18.1";
    };

    volumes.${logs_volume_name} = aln.lib.mkVolume logs_volume_name {};
    volumes.${db_name} = aln.lib.mkVolume db_name {};
  };

  sops.templates.authelia_db_env = {
    mode = "0400";
    content = ''
      POSTGRES_PASSWORD=${config.sops.placeholder.authelia_postgres_password}
    '';
  };

  sops.secrets = (lib.genAttrs 
    [
      "authelia_session_secret"
      "authelia_storage_encryption_key"
      "authelia_postgres_password"
      "authelia_oidc_jwk_key_priv"
    ]
    (secret_key: {
      # key in sops is: authelia/secret_key_without_authelia_prefix
      key = "authelia/" + builtins.substring 9 (builtins.stringLength secret_key) secret_key;
    })
  );
}
