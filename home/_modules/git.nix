{ ... }:
{
  programs.git = {
    enable = true;
    settings= {
      push.autoSetupRemote = true;
    };
    attributes = [
      "*.pdf binary"
      "*.png binary"
      "*.jpg binary"
      "*.jpeg binary"
      "*.webp binary"
    ];
  };
}

