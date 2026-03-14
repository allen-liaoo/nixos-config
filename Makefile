GIT_REPO := https://github.com/allen-liaoo/nixos-config.git
# get directory of the Makefile
DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
FLAKE = $(DIR)\#$(HOST)
HOST_KEY_PATH ?= /etc/ssh/ssh_host_ed25519_key
NIX_FLAGS := --extra-experimental-features "nix-command flakes"

.PHONY: help os-rebuild flake-update flake-check gc setup disko os-install gen-host-key

help:
	@echo "Common targets:"
	@echo "  os-rebuild    - Rebuild the NixOS configuration"
	@echo "  flake-update  - Update flake inputs"
	@echo "  flake-check   - Check the flake for errors"
	@echo "  gc            - Collect Nix garbage"
	@echo "One-time-use targets:"
	@echo "  disko         - Run disko to format and mount disks"
	@echo "  os-install    - Install NixOS using the specified flake#host"
	@echo "  gen-host-key  - Generate host age key for .sops.yaml (based on ssh host public key)"
	
env:
	@if [ -z "$(HOST)" ]; then \
		echo "HOST is not set"; \
		exit 1; \
	elif [ -z "$(CONFUSER)" ]; then \
		echo "CONFUSER is not set, setting to current user: $(USER)"; \
		export CONFUSER=$(USER); \
	fi

os-rebuild: env
	@sudo nixos-rebuild switch --flake $(FLAKE)

flake-update: env
	@nix $(NIX_FLAGS) flake update

flake-check:
	@nix $(NIX_FLAGS) flake check

gc: env
	@sudo nix-collect-garbage -d

disko: env
	sudo nix $(NIX_FLAGS) run github:nix-community/disko/latest -- --mode destroy,format,mount --flake $(FLAKE)
	sudo nixos-generate-config --no-filesystems --root /mnt --dir $(DIR)
	@lsblk

os-install: env
	sudo nixos-install --no-channel-copy --no-root-password --flake $(FLAKE) --root /mnt
	@echo "Cloning configuration repository to /mnt$(DIR) and linking it to /mnt/etc/nixos..."
	@sudo -u $(CONFUSER) git clone $(GIT_REPO) /mnt$(DIR)
	@sudo ln -s /mnt$(DIR) /mnt/etc/nixos
	@echo "NixOS installed. Please reboot and run 'make os-setup' to use new configuration."

gen-host-key:
	nix shell nixpkgs#ssh-to-age --run 'cat $(HOST_KEY_PATH).pub | ssh-to-age'
	@echo "Add the above output .sops.yaml under the 'keys' section, under '&hosts'."
