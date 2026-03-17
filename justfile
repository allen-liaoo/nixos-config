current_hostname := `hostname -s`
current_user := `whoami`
nix_config_path := "$HOME/nix-config"
host_key_path := env_var_or_default("HOST_KEY_PATH", "/etc/ssh/ssh_host_ed25519_key")
nix_flags := "--extra-experimental-features 'nix-command flakes'"

dir := justfile_directory()

# Default target — list all targets
[private]
default:
    @just --list

# Rebuild the NixOS config
[group("update")]
os-switch host=current_hostname:
    @echo "Running for host: {{host}}"
    sudo nixos-rebuild switch --flake {{dir}}#{{host}}

# Rebuild a Home Manager config
[group("update")]
hm-switch user=current_user:
    @echo "Running for user: {{user}}"
    home-manager switch --flake {{dir}}#{{user}}

# Update flake inputs
[group("update")]
fl-update:
    nix {{nix_flags}} flake update

# check the flake for errors
[group("utility")]
fl-meta:
    nix {{nix_flags}} flake metadata .

# check the flake for errors
[group("utility")]
fl-check:
    nix {{nix_flags}} flake check

# Collect Nix garbage
[group("utility")]
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

# Switch current repository remote url (Only run after home-manager setup)
[group("initial")]
repo-switch-ssh:
    git --git-dir {{nix_config_path}}/.git remote set-url origin git@gh_nix_config:allen-liaoo/nix-config.git
# Note: See hm module ssh.nix for host name gh_nix_config
