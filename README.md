# Nix-Config
My NixOS and Home-Manager Configs

## Features
### Nix-Specific
- Declarative disks partitioning via [disko](https://github.com/nix-community/disko/) [⌃](host/barrybenson/disko.nix).
- Secrets management via [sops-nix](https://github.com/Mic92/sops-nix) [⌃](host/_modules/sops.nix),[⌃](home/_modules/sops.nix).
- Wipe storage on boot via [impermanence](https://github.com/nix-community/impermanence) [⌃](host/_modules/impermanence.nix).

### Dots
| Feature | Component |
|---|---|
| Shell | [Fish](https://fishshell.com)[⌃](/home/_modules/shell/fish.nix), [Starship](https://starship.rs)[⌃](/home/_modules/shell/starship.nix) |
| Editor | [Vim](https://www.vim.org)[⌃](/home/_modules/terminal/vim.nix) |
| WM | [Niri](https://niri-wm.github.io/niri/)[⌃](/home/_modules/de/niri) |
| Desktop Shell | [DankMaterialShell](https://danklinux.com/)[⌃](/home/_modules/de/dms) |
| Theming | [Stylix](https://nix-community.github.io/stylix/)[⌃](/home/_modules/stylix.nix) |
| Terminal | [Alacritty](https://alacritty.org/)[⌃](/home/_modules/program/alacritty.nix) |
| Launcher | [Vicinae](https://www.vicinae.com/)[⌃](/home/_modules/program/vicinae.nix) |
| Browser | [Firefox](https://www.firefox.com)[⌃](/home/_modules/program/firefox) |

### Self-Hosted
Podman containers via [quadlet-nix](https://seiarotg.github.io/quadlet-nix/) (Rootful, `userns=auto`)[⌃](host/barrybenson/selfhosted).
| Service | Component |
|---|---|
| Authentication | [Authelia](https://www.authelia.com/)[⌃](/host/barrybenson/selfhosted/authelia) |
| Reverse Proxy | [Caddy](https://caddyserver.com/)[⌃](/host/barrybenson/selfhosted/rproxy) |
| Adblock | [Pihole](https://pi-hole.net/)[⌃](/host/barrybenson/selfhosted/pihole.nix) |
| CalDAV/CardDAV | Radicale (TODO) |
| Music Stats | Multi-scrobbler, Koito (TODO) |
| RSS Aggregator | FreshRSS (TODO) |

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
Modules in `_modules` are self gating, meaning they determine if they should be enabled or not by looking at the context.
This is different from how they're usually implemented, where hosts and users conditionally import modules or "presets", and one needs to carefully maintain lists of imports. 
Consequently, modules are always wholly imported, and most `default.nix` on modules just import every file in its directory and every
`default.nix` in subdirectories.

### Project Location in any system
It is required that the project is cloned to `~/nix-config` when using the Home-Manager modules.
This allows symlinking out of store files to work correctly, and sidesteps file permission issues.

## Hosts
| Name | Hardware | Type | Note | Status |
|---|---|---|----|---|
|barrybenson|Beelink Mini PC (Ryzen 7 5700U)|server|Headless homeserver mostly running containers. Containers setup in progress.|🚧|
|theseus|Framework Laptop 13 (Ryzen AI 5 340)|laptop|Currently on Fedora with Home Manager.|🚧|
|louisxvi|Macbook Air M1|laptop|Broke the screen so now it's running "headless". Plan to test Asahi with NixOS. Currently retired.|📝|
|ionobro|IONOS VPS (1G RAM, 10G Storage)|server|Acts as the router/firewall for barrybenson who is behind CGNAT. I need a minimal NixOS install to run wireguard + nftables.|📝|
|guinea|QEMU/KVM|VM|Used to build this config. On theseus.|🚧|

🚧 - In progress
📝 - Planing

## Details

### Secrets
- Each NixOS host generates a ssh host key on initial install, which is used to derive the host age key (on boot). The age key is then used to decrypt host secrets. 
- For each user of a NixOS host, the host decrypts the user's password for its own setup, and the user's age key to a location that the home-manager sops expects (`~/.config/sops/age/key.txt`).
  The user's home manager config then uses the age key to decrypt secrets.
- Each NixOS host should have access to the secret `nix_config_deploy` which is used to push to this repository. Additionally, each authorized user should have this secret under `~/.ssh` as well.

### Networking
`barrybenson` hosts services and lives behind CGNAT. It connects via a wireguard tunnel to `ionobro`, who forwards packets destined to the right port to `barrybenson` without source nat. Then `barrybenson` replies through tunnel. On the `barrybenson` side, its outgoing traffic goes through wireguard if it is a response from some incoming traffic from the tunnel, otherwise it goes through the normal internet. This is achieved via nftables for policy based routing of Wireguard[⌃](/host/barrybenson/network.nix).

