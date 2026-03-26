# Nix-Config
My NixOS and Home-Manager Configs

Featuring:
- Declarative disks partitioning with `disko`
- Secrets management via `sops-nix`
- Podman rootless containers via `quadlet-nix`
- Impermanence for servers

Todo:
- Todo: Impermanence for home dirs while auto activating (and perserving) home-manager
- LUKS and lanzaboot for laptops

## Structure
- `hosts` - NixOS host configurations, including hardware, system configs and host-specific user configs
  - `_modules` - nix modules for nixos configs
  - `<hostname>` - configs for the host, should contain `configuration.nix` and others
- `home` - **Standalone** user home configurations, should include as many general-purposed programs/services as possible for portability
  - `_modules` - nix modules for home-manager configs 
  - `<username>` - configs for the user, including host-specific user configs
- `lib`- custom library functions
- `inventory` - metadata about users and hosts and valid pairings, used by home/nixos modules, users, and hosts
- `ctx.nix` - supplies current eval context to NixOS/Home modules (i.e. current host and user inventory info)
- `secrets` and `.sops.yaml` - read by sops-nix for host and user secrets at various sops.nix files throughout home and host directories

### `aln` namespace
To avoid namespace conflicts, everything I want to expose to nix modules live inside of the namespace `aln`.
- `aln.lib` is `/lib`
- `aln.inventory` is `/inventory`
- `aln.ctx` is `ctx.nix`

### Self-Gating Modules
Modules in `_modules`are self gating, meaning they determine if they should be enabled or not by looking at the context.
This is different from how they're usually implemented, where hosts and users conditionally import modules or "presets", and one needs to carefully maintain lists of imports. 
Consequently, modules are always wholly imported, and most `default.nix` on modules just import every file in its directory and every
`default.nix` in subdirectories.

### Project Location in any system
For each user of NixOS/non-NixOS machines who can edit this repository, it is required that the project is cloned to `~/nix-config`. 
This allows symlinking out of store files in home-manager modules to work correctly, and sidesteps file permission issues.

## Hosts
| Name | Hardware | Type | Note | Status |
|---|---|---|----|---|
|barrybenson|Beelink Mini PC (Ryzen 7 5700U)|server|Headless homeserver mostly running containers. Installed NixOS, setup in progress.|🚧|
|theseus|Framework Laptop 13 (Ryzen AI 5 340)|laptop|Plan to run hyprland. Currently on Fedora Gnome.|📝|
|louisxvi|Macbook Air M1|laptop|Broke the screen so now it's running "headless". Plan to test Asahi with NixOS. Currently retired.|📝|
|ionobro|IONOS VPS (1G RAM, 10G Storage)|VM|Acts as the router for barrybenson who is behind CGNAT. I need a minimal NixOS install to run wireguard + nftables.|📝|
|guinea|QEMU/KVM|VM|Used to build this config. Currently on theseus.|🚧|

🚧 - In progress
📝 - Planing

## Secrets
Handled by `sops-nix`. In particular:
- Each NixOS host generates a ssh host key on initial install, which is used to derive the host age key (on boot). The age key is then used to decrypt host secrets. 
- For each user of a NixOS host, the host decrypts the user's password for its own setup, and the user's age key to a location that the home-manager sops expects (`~/.config/sops/age/key.txt`).
  The user's home manager config then uses the age key to decrypt secrets.
- Each NixOS host should have access to the secret `nix_config_deploy` which is used to push to this repository. Additionally, each authorized user should have this secret under `~/.ssh` as well.
