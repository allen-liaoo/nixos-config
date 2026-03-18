# Nix-Config
My NixOS and Home-Manager Configs

## Structure
- `hosts` - NixOS host configurations, including hardware, system configs and host-specific user configs (at a system level)
  - `_modules` - nix modules for nixos configs, imported at will by presets and hosts
  - `<hostname>` - configs for the host, should contain `configuration.nix` and others
  - presets - `core.nix` etc, shared by multiple hosts
- `home` - **Standalone** user home configurations, should include as many general-purposed use programs/services as possible for portability
  - `_modules` - nix modules for home-manager configs, imported at will by presets and users
  - `<username>` - configs for the user, including host-specific user configs
  - presets - `core.nix` etc, shared by multiple users
- `lib`- custom library functions exposed under my namespace `aln.lib`
- `meta.nix` - supported host and user pairings (for each nixos host) and their metadata, used by both users and hosts
- `secrets` and `.sops.yaml` - read by sops-nix for host and user secrets at various sops.nix files throughout home and user directories
