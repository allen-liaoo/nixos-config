{ config, lib, aln, pkgs, ... }@args:

let
  name = "authelia";
  dbName = name + "_db";
  podName = name + "-pod";
  logsVolumeName = name + "_logs";
  usersDatabase = import ./users_database.nix; 
  # sops of user hashed passwords
  password_sops_name_from_user = (name: "authelia_users_${name}_password_hashed");
in
{
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) containers images pods volumes;
  in {
    # authelia container
    containers.${name} = aln.lib.mkContainer name {
      containerConfig = {
        image = images.${name}.ref;
        pod = pods.${podName}.ref;
        startWithPod = true;
        volumes = [
          "${./configuration.yml}:/config/configuration.yml:ro"
          "${config.sops.templates.users_database.path}:/config/users_database.yml:ro,U"
          "${volumes.${logsVolumeName}.ref}:/logs:rw,U"

          "${config.sops.secrets.authelia_session_secret.path}:/run/secrets/session_secret:ro,U"
          "${config.sops.secrets.authelia_storage_encryption_key.path}:/run/secrets/storage_encryption_key:ro,U"
          "${config.sops.secrets.authelia_postgres_password.path}:/run/secrets/postgres_password:ro,U"
          "${config.sops.secrets.authelia_oidc_jwk_key_priv.path}:/run/secrets/oidc_jwk_key_priv:ro,U"
        ];
        environments = {
          X_AUTHELIA_CONFIG = "/config/configuration.yml";
          X_AUTHELIA_CONFIG_FILTERS = "template";
        };
        healthCmd = "/app/healthcheck.sh";
        healthInterval = "5m";
        healthStartPeriod = "5s";
      };
      unitConfig = {
        Requires = containers.${dbName}.ref;
        After = containers.${dbName}.ref;
      };
    };

    # authelia database container
    containers.${dbName} = aln.lib.mkContainer dbName {
      containerConfig = {
        image = images.${dbName}.ref;
        pod = pods.${podName}.ref;
        startWithPod = true;
        volumes = [
          "${volumes.${dbName}.ref}:/var/lib/postgresql/18/data:rw"
        ];
        environments = {
          POSTGRES_DB = "authelia";
          POSTGRES_USER = "authelia";
        };
        environmentFiles = [ config.sops.templates.authelia_db_env.path ];
      };
    };

    pods.${podName} = aln.lib.mkPod podName {
      podConfig = {
        userns = "auto";
        publishPorts = [ "9080:80" ];
      };
    };

    images.${name} = aln.lib.mkImage name {
      imageConfig.image = "docker.io/authelia/authelia:latest";
    };

    images.${dbName} = aln.lib.mkImage dbName {
      imageConfig.image = "docker.io/library/postgres:18.1";
    };

    volumes.${logsVolumeName} = aln.lib.mkVolume logsVolumeName {};
    volumes.${dbName} = aln.lib.mkVolume dbName {};
  };

  sops.secrets =
    # secrets for authelia to function
    lib.listToAttrs (map (secret_key: {
      name = "authelia_" + secret_key;
      value = {
        sopsFile = aln.lib.relToRoot "secrets/services/authelia.yaml";
        key = "authelia/" + secret_key;
      };
    }) [
      "session_secret"
      "storage_encryption_key"
      "postgres_password"
      "oidc_jwk_key_priv"
    ])
    //
    # secrets for users of authelia
    lib.listToAttrs (map (user_name: {
      name = password_sops_name_from_user user_name;
      value = {
        sopsFile = aln.lib.relToRoot "secrets/services/authelia_users.yaml";
        key = "${user_name}/password_hashed";
      };
    }) (builtins.attrNames usersDatabase.users));

  # inject secret as env var to db
  sops.templates.authelia_db_env = {
    mode = "0400";
    content = ''
      POSTGRES_PASSWORD=${config.sops.placeholder.authelia_postgres_password}
    '';
  };

  # generate users_database.yml from users_database.nix and add password from sops secrets
  sops.templates.users_database = {
    mode = "0400";
    # json is subset of yaml
    content = builtins.toJSON {
      users = lib.mapAttrs (user_name: user:
        user // {
          password = config.sops.placeholder.${password_sops_name_from_user user_name};
        }
      ) usersDatabase.users;
    };
  };
}
