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

## Hosts
| Name | Hardware | Type | Note | Status |
|---|---|---|----|---|
|barrybenson|Beelink Mini PC (Ryzen 7 5700U)|server|Headless homeserver mostly running containers. Currently on Debian.|📝|
|theseus|Framework Laptop 13 (Ryzen AI 5 340)|laptop|Plan to run hyprland. Currently on Fedora Gnome.|📝|
|louisxvi|Macbook Air M1|laptop|Broke the screen so now it's running "headless". Plan to test Asahi with NixOS. Currently retired.|📝|
|guinea|QEMU/KVM|VM|🚧|Used to build this config. Currently on theseus.|

## Project Location in System
For each user of NixOS/non-NixOS machines who can edit this repository, it is required that the project is cloned to `~/nix-config`. This allows symlinking out of store files in home-manager modules to work correctly, and sidestep file permission issues.

## Secrets
Handled by `sops-nix`. In particular:
- Each NixOS host generates a ssh host key on initial install, which is used to derive the host age key (on boot). The age key is then used to decrypt host secrypts. 
- For each user of a NixOS host, the host decrypts the user's password for its own setup, and the user's age key to a location that the home-manager sops expects (`~/.config/sops/age/key.txt`).
  The user then uses the age key to decrypt secrets.
- Each NixOS host should have access to the secret `nix_config_deploy` which is used to push to this repository. Additionally, each authorized user should have this secret under `~/.ssh` as well.
