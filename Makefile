# get directory of the Makefile
DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
FLAKE = $(DIR)\#$(HOST)
NIX_FLAGS += --extra-experimental-features "nix-command flakes"

.PHONY: help env setup disko nixos-install nixos-rebuild nix-gc flake-update flake-check

help:
	@echo "Common targets:"
	@echo "  os-rebuild   - Rebuild the NixOS configuration"
	@echo "  flake-update    - Update flake inputs"
	@echo "  flake-check     - Check the flake for errors"
	@echo "  gc          - Collect Nix garbage"
	@echo "One-time-use targets:"
	@echo "  setup           - Set up the installation environment"
	@echo "  disko           - Run disko to format and mount disks (one time use)"
	@echo "  os-install   - Install NixOS using the specified flake"
	
env:
	@if [ -z "$(HOST)" ]; then \
		echo "HOST is not set"; \
		exit 1; \
	fi

setup:
	@export EDITOR=vim

disko: env
	sudo nix $(NIX_FLAGS) run github:nix-community/disko/latest -- --mode destroy,format,mount --flake $(FLAKE)
	sudo nixos-generate-config --no-filesystems --root /mnt --dir $(DIR)
	@lsblk

os-install: env
	sudo nixos-install --no-channel-copy --no-root-password --flake $(FLAKE) --root /mnt
	@echo "Cloning configuration repository to /mnt$(DIR) and linking it to /mnt/etc/nixos..."
	@git clone https://github.com/allen-liaoo/nixos-config.git /mnt$(DIR)
	@sudo ln -s /mnt$(DIR) /mnt/etc/nixos
	@echo "NixOS installed. Please reboot and run 'make os-rebuild' to switch to the new configuration."

os-rebuild: env
	@sudo nixos-rebuild switch --flake $(FLAKE)

gc: env
	@sudo nix-collect-garbage -d

flake-update: env
	@nix $(NIX_FLAGS) flake update

flake-check:
	@nix $(NIX_FLAGS) flake check
