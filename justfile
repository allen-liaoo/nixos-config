current_hostname := `hostname -s`
current_user := `whoami`
nix_config := "NIX_CONFIG=\"extra-experimental-features = nix-command flakes pipe-operators\"" # setting this as merely a flag does not work; need the config to persist on child processes
host_key_path := env_var_or_default("HOST_KEY_PATH", "/etc/ssh/ssh_host_ed25519_key")
nix_query_param := "?submodules=1"

dir := justfile_directory()

# Default target — list all targets
[private]
default:
    @just --list

# Rebuild the NixOS config
[group("update")]
os-switch host=current_hostname:
    @echo "Running for host: {{host}}"
    sudo {{nix_config}} \
    nixos-rebuild switch --flake {{dir}}{{nix_query_param}}#{{host}}

# Rebuild a Home Manager config
[group("update")]
hm-switch user=current_user host=current_hostname:
    @echo "Running for user: {{user}}"
    {{nix_config}} \
    home-manager switch --flake {{dir}}{{nix_query_param}}#{{user}}@{{host}}

# Update flake inputs
[group("update")]
fl-update:
    {{nix_config}} \
    nix flake update

# Reencrypt sops secrets with new age keys
[group("update")]
sops-rekey:
    cd {{dir}}/secrets && \
    {{nix_config}} \
    nix develop --command bash -c \
    'for file in $(find . \( -name "*.yaml" -o -name "*.json" -o -name "*.env" \)); do \
      sops updatekeys $file; \
    done'

# run nix command with experimental features enabled
[group("utility")]
nix +cmd:
    {{nix_config}} \
    nix {{cmd}}

# check the flake for errors
[group("utility")]
fl-meta:
    nix flake metadata .

# check the flake for errors
[group("utility")]
fl-check: 
    {{nix_config}} \
    nix flake check

# Enter dev shell
[group("utility")]
dev:
    {{nix_config}} \
    nix develop

# Collect Nix garbage
[group("utility")]
gc:
    sudo nix-collect-garbage -d

# Initial targets
# Dont infer host/user when config has not been applied

# Run disko to format and mount disks
[group("initial")]
disko host:
    sudo {{nix_config}} \
    nix  run github:nix-community/disko/latest -- \
        --mode destroy,format,mount \
        --flake "{{dir}}#{{host}}"
    @lsblk

# Generate SSH host key, install to /mnt (and /mnt/persist if persist=true), and print age key
[group("initial")]
gen-install-host-key host persist:
    #!/usr/bin/env bash
    set -euxo pipefail
    echo "Generating SSH host key..."
    ssh-keygen -t ed25519 -f /tmp/ssh_host_ed25519_key -N "" -C "" -q

    echo "Installing key to /mnt/etc/ssh..."
    sudo mkdir -p /mnt/etc/ssh
    sudo install -m 600 /tmp/ssh_host_ed25519_key     /mnt/{{host_key_path}}
    sudo install -m 644 /tmp/ssh_host_ed25519_key.pub /mnt/{{host_key_path}}.pub

    if [ "{{persist}}" = "true" ]; then
        echo "Installing key to /mnt/persist/etc/ssh..."
        sudo mkdir -p /mnt/persist/etc/ssh
        sudo install -m 600 /tmp/ssh_host_ed25519_key     /mnt/persist/{{host_key_path}}
        sudo install -m 644 /tmp/ssh_host_ed25519_key.pub /mnt/persist/{{host_key_path}}.pub
    fi

    echo "\nAge public key (add to .sops.yaml in machine with sops admin key):"
    nix-shell -p ssh-to-age --run 'cat /tmp/ssh_host_ed25519_key.pub | ssh-to-age'

# Generate hardware configuration
[group("initial")]
gen-hardware-config:
    mkdir -p {{dir}}/tmp
    sudo nixos-generate-config --no-filesystems --root /mnt --dir {{dir}}/tmp
    @echo "Hardware configuration generated at {{dir}}/tmp/hardware-configuration.nix. Copy it to remote, commit, and push to apply it to the flake."

# Install NixOS using the specified hostname
[group("initial")]
os-install host:
    sudo {{nix_config}} \
    nixos-install --no-channel-copy --no-root-password \
        --flake "{{dir}}#{{host}}" \
        --root /mnt
    @echo "NixOS installed. Please reboot, clone repository, and run 'just os-setup' to use new configuration."

# Switch current repository remote url (Only run after home-manager setup)
[group("initial")]
repo-switch-ssh:
    git --git-dir {{dir}}/.git remote set-url origin git@gh_nix_config:allen-liaoo/nix-config.git
# Note: See hm module ssh.nix for host name gh_nix_config
