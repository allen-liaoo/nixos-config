# Nix-Config
My NixOS and Home-Manager Configs

## Features
### Dots
**Standalone** home-manager modules.
| Feature | Component |
|---|---|
| Shell | [Fish](https://fishshell.com)[⌃](/home/_modules/shell/fish.nix), [Starship](https://starship.rs)[⌃](/home/_modules/shell/starship.nix) |
| Editor | [Neovim](https://neovim.io)[⌃](https://github.com/allen-liaoo/nvimx), [Vim](https://www.vim.org)[⌃](/home/_modules/terminal/vim.nix) |
| WM | [Niri](https://niri-wm.github.io/niri/)[⌃](/home/_modules/de/niri) |
| Desktop Shell | [DankMaterialShell](https://danklinux.com/)[⌃](/home/_modules/de/dms) |
| Theming | [Matugen](https://iniox.github.io/#matugen)[⌃](/home/_modules/de/matugen.nix) |
| Terminal | [Alacritty](https://alacritty.org/)[⌃](/home/_modules/app/alacritty.nix) |
| Launcher | [Vicinae](https://www.vicinae.com/)[⌃](/home/_modules/app/vicinae.nix) |
| Browser | [Firefox](https://www.firefox.com)[⌃](/home/_modules/app/browser/firefox) |

### Self-Hosted
Podman containers via [quadlet-nix](https://seiarotg.github.io/quadlet-nix/) (Rootful, `userns=auto`)[⌃](host/barrybenson/selfhosted).
| Service | Component |
|---|---|
| Authentication | [Authelia](https://www.authelia.com/)[⌃](/host/barrybenson/selfhosted/authelia) |
| Reverse Proxy | [Caddy](https://caddyserver.com/)[⌃](/host/barrybenson/selfhosted/rproxy) |
| Adblock | [Pihole](https://pi-hole.net/)[⌃](/host/barrybenson/selfhosted/pihole.nix) |
| CalDAV/CardDAV | Radicale (TODO) |
| Music Stats | Multi-scrobbler, Koito (TODO) |
| Torrent Indexer | [Jackett](https://github.com/Jackett/Jackett)[⌃](/host/barrybenson/selfhosted/jackett.nix) |
| RSS Aggregator | FreshRSS (TODO) |
| Nix Binary Cache | TODO |

### Nix-Specific
- Secrets management via [sops-nix](https://github.com/Mic92/sops-nix) [⌃](host/_modules/sops.nix),[⌃](home/_modules/sops.nix).
- Declarative disks partitioning via [disko](https://github.com/nix-community/disko/) with BTRFS and LUKS [⌃](host/theseus/disko.nix).
- Wipe storage on boot via [impermanence](https://github.com/nix-community/impermanence) [⌃](host/_modules/fs/impermanence.nix).

## Structure
- `host` - NixOS host configurations
  - `_modules` - nix modules for nixos configs
  - `<hostname>` - configs for each host
- `home` - Home manager configurations
  - `_modules` - nix modules for standalone home-manager configs 
  - `<username>` - configs for the user, including host-specific user configs
- `lib`- my library functions
- `inventory` - metadata about users, hosts, and valid pairings
- `ctx.nix` - supplies current eval context to NixOS/Home modules (i.e. current host and user info from inventory)
- `secrets` and `.sops.yaml` - read by sops-nix for host and user secrets at various sops.nix files throughout home and host directories
- `shell.nix` - devShells of this repository, notably including distinct Neovim instances and development environments for `home` and `host` dir (activated via direnv).

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
|theseus|Framework Laptop 13 (Ryzen AI 5 340)|laptop|My daily driver. NixOS + LUKS + everything in dots.|✅|
|barrybenson|Beelink Mini PC (Ryzen 7 5700U)|server|Headless homeserver with impermanence. Containers setup in progress.|✅|
|louisxvi|Macbook Air M1|laptop|Broke the screen so now it's "headless". Plan to run Asahi with NixOS. Currently retired.|-|
|ionobro|IONOS VPS (1G RAM, 10G Storage)|server|Acts as the router/firewall for barrybenson who is behind CGNAT. I need a minimal NixOS install to run wireguard + nftables.|📝|
|guinea|QEMU/KVM|VM|Used to build this config. Need to configure declaratively on theseus.|✅|

✅ - Setup completed 
🚧 - In progress
📝 - Planning

## Details

### Secrets
- Each NixOS host generates a ssh host key on initial install, which is used to derive the host age key (on boot). The age key is then used to decrypt host secrets. 
- For each user of a NixOS host, the host decrypts the user's password for its own setup, and the user's age key to a location that the home-manager sops expects (`~/.config/sops/age/key.txt`).
  The user's home manager config then uses the age key to decrypt secrets.
- Each user should have access to the secret `nix_config_deploy` which is used to push to this repository. Additionally, each authorized user should have this secret under `~/.ssh` as well.

### Firefox-based Browsers
My firefox (HM) module configs can be applied to any firefox-based browser, such as `floorp`, `librewolf`, or even `glide` (from external flake). 
For examples, see [firefox.nix](home/_modules/app/browser/firefox.nix) and [glide.nix](home/_modules/app/browser/glide.nix).
Both share these centralized configs: 
- [firefox/config](home/_modules/app/browser/firefox/config) - Shared policies, settings, extensions, and my custom module configs
- [firefox/mkModule](home/_modules/app/browser/firefox/config) - My custom modules, which includes:
  - `pywalfox.nix`- for setting up [pywalfox](https://github.com/Frewacom/pywalfox) (colors and system theming) native messaging host and extension
  - `wavefox.nix` - for setting up [WaveFox](https://github.com/QNetITQ/WaveFox) (ui styling)

In particular, the custom modules are meant to be merged with firefox-based browser modules such as `programs.firefox`, `programs.librewolf`, etc.
This is achieved by providing the module path (i.e. `["programs" "firefox"]` to `firefox/mkModule`, which constructs the module based on the module path. Note that certain option declarations are only legal because submodules are [extensible option types](https://nixos.org/manual/nixos/stable/#sec-option-declarations-eot).

### Networking
- `ionobro` is my VPS which connects clients to my homeserver, `barrybenson`, via wireguard. It forwards packets destined to the right port to `barrybenson` without source nat. 
- `barrybenson` hosts services and lives behind CGNAT. Its outgoing traffic goes through wireguard if it is a response from some incoming traffic from the tunnel, otherwise it goes through the normal internet. This is achieved via nftables for policy based routing of Wireguard[⌃](/host/barrybenson/network.nix).

