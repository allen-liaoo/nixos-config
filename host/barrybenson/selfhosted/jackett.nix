{ config, lib, aln, pkgs, ... }:

let
  name = "jackett";
  flName = "flaresolverr";
  podName = name + "-pod";
in
{
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) containers images pods volumes;
  in {
    # jackett container
    containers.${name} = aln.lib.mkContainer name {
      containerConfig = {
        image = images.${name}.ref;
        pod = pods.${podName}.ref;
        userns = ""; # pod sets userns, container shouldn't
        startWithPod = true;
        volumes = [
          "${volumes.${name}.ref}:/config:rw,U"
        ];
        environments = {
          PUID = "0";
          PGID = "0";
        };
      };
    };

    # flaresolvarr container
    containers.${flName} = aln.lib.mkContainer flName {
      containerConfig = {
        image = images.${flName}.ref;
        pod = pods.${podName}.ref;
        userns = ""; # pod sets userns
        startWithPod = true;
      };
    };

    pods.${podName} = aln.lib.mkPod podName {
      podConfig = {
        publishPorts = [ "20117:9117" ];
      };
    };

    images.${name} = aln.lib.mkImage {
      imageConfig.image = "docker.io/linuxserver/jackett:latest";
    };

    images.${flName} = aln.lib.mkImage {
      imageConfig.image = "docker.io/flaresolverr/flaresolverr:latest";
    };

    volumes.${name} = aln.lib.mkVolume name {};
  };
}
