git_repo := "https://github.com/allen-liaoo/nixos-config.git"
host_key_path := env_var_or_default("HOST_KEY_PATH", "/etc/ssh/ssh_host_ed25519_key")
nix_flags := "--extra-experimental-features 'nix-command flakes'"

dir := justfile_directory()

# Default target — list all targets
[private]
default:
    @just --list

# Rebuild the NixOS config
[group("update")]
os-switch host="$HOSTNAME":
    @echo "Running for host: {{host}}"
    sudo nixos-rebuild switch --flake {{dir}}#{{host}}

# Rebuild a Home Manager config
[group("update")]
hm-switch user="$USER":
    @echo "Running for user: {{user}}"
    home-manager switch --flake {{dir}}#{{user}}

# Rebuild all Home Manager configs for host
[group("update")]
hm-switch-all host="$HOSTNAME":
    @echo "Running for host: {{host}}"
    nix {{nix_flags}} eval .#homeConfigurations --apply 'builtins.attrNames' --json \
        | tr -d '[]"' | tr ',' '\n' \
        | grep '@{{host}}$' \
        | sed 's/@{{host}}$//' \
        | xargs -I{} just home-switch {{host}} {}

# Rebuild both NixOS and HomeManager configs
switch-all host="$HOSTNAME":
    just os-switch {{host}}
    just home-switch-all {{host}}

# Update flake inputs
[group("update")]
fl-update:
    nix {{nix_flags}} flake update

# Check the flake for errors
fl-check:
    nix {{nix_flags}} flake check

hm-check user="$USER":
    home-manager -n switch --flake {{dir}}#{{user}}

# Collect Nix garbage
gc:
    sudo nix-collect-garbage -d

# Initial targets
# Dont infer host/user when config has not been applied

# Run disko to format and mount disks
[group("initial")]
disko host:
    sudo nix {{nix_flags}} run github:nix-community/disko/latest -- \
        --mode destroy,format,mount \
        --flake "{{dir}}#{{host}}"
    @lsblk

# Install NixOS using the specified hostname
[group("initial")]
os-install host:
    sudo nixos-install --no-channel-copy --no-root-password \
        --flake "{{dir}}#{{host}}" \
        --root /mnt
    @echo "NixOS installed. Please reboot, clone repository, and run 'just os-setup' to use new configuration."

# Link config, generate hardware-configuration.nix, and apply configs 
[group("initial")]
os-setup host:
    @echo "Linking {{dir}} to /etc/nixos..."
    sudo ln -s {{dir}} /etc/nixos
    @echo "Adding hardware-configuration.nix... remember to commit it"
    sudo nixos-generate-config --no-filesystems --root /mnt --dir {{dir}}
    just switch-all {{host}}

# Generate host age key for .sops.yaml (based on ssh host public key)
[group("initial")]
gen-host-key:
    nix-shell -p ssh-to-age --run 'cat {{host_key_path}}.pub | ssh-to-age'
    @echo "Add the above output to .sops.yaml under 'keys' > '&hosts'."

[group("initial")]
secrets-setup host="$HOSTNAME":
    just switch-all {{host}}
    git remote set-url origin {{git_repo}}
