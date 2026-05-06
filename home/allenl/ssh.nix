{ lib, config, alnLib, inventory, ... }:


let
  keys = [
    "personal"
    "liao0144"
  ];
in
{
  programs.ssh.matchBlocks = {
    "ionobro" = {
      hostname = "allenl.me";
      user = "allenliao"; # TODO: Change to al
    };
    "barrybenson" = with inventory; {
      hostname = hosts.barrybenson.data.wg_ip;
      user = users.al.name;
      proxyJump = "ionobro";
      serverAliveInterval = 60;
      serverAliveCountMax = 10;
    };
    # "guinea" = {
    #   hostname = "192.168.122.100";
    #   user = "pig";
    # };
    "*".identityFile = (map (key: 
      config.sops.secrets."ssh_allenl_${key}".path
    ) keys);
  };

  sops.secrets = lib.mergeAttrsList (map (key: {
    "ssh_allenl_${key}" = {
      sopsFile = alnLib.relToRoot "secrets/user/allenl/ssh.yaml";
      mode = "0400";
      path = config.home.homeDirectory + "/.ssh/" + key;
      inherit key;
    };
  }) keys);
}
