{ ... }:
{
  programs.git = {
    enable = true;
    settings= {
      push.autoSetupRemote = true;
    };
    attributes = [ "*.pdf binary" ];
  };
}

