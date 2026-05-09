{
  lib,
  pkgs,
  pkgs-aln,
  ctx,
  ...
}:

lib.mkIf (!ctx.host.is.server) {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      theme = "system"; # TODO: change to tui on next HM version
      permission = {
        "*" = "ask";
        bash = {
          "*" = "ask";
          "rm *" = "deny";
          "grep *" = "allow";
        };
        grep = "allow";
        glob = "allow";
        question = "allow";
      };
    };
  };

  programs.mcp = {
    enable = true;
    servers = {
      nix = {
        type = "local";
        command = lib.getExe pkgs.mcp-nixos;
      };
      typst = {
        type = "local";
        command = lib.getExe pkgs-aln.typst-mcp;
      };
    };
  };
}
