{ inputs, ... }:

# add this in homeConfigurations
# vscode-server.nixosModules.home
{
  imports = [
    inputs.vscode-server.nixosModules.home
  ];

  services.vscode-server.enable = true;
}
