{ ... }:

{
  virtualisation.quadlet.enable = true;
  virtualisation.quadlet.containers.echo-server = {
                autoStart = true;
                serviceConfig = {
                    RestartSec = "10";
                    Restart = "always";
                };
                containerConfig = {
                    name = "echo";
                    image = "docker.io/mendhak/http-https-echo:31";
                    publishPorts = [ "127.0.0.1:8080:8080" ];
                    userns = "keep-id";
                };
            };
}
