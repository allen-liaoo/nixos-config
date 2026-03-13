FLAKE = ./.\#$(HOST)
DIR := $(shell pwd)
NIX_FLAGS += --extra-experimental-features "nix-command flakes"

.PHONY: help env setup disko nixos-install nixos-rebuild nix-gc flake-update flake-check

help:
	@echo "Available targets:"
	@echo "  disko           - Run disko to format and mount disks (one time use)"
	@echo "  nixos-install   - Install NixOS using the specified flake"
	@echo "  nixos-rebuild   - Rebuild the NixOS configuration"
	@echo "  nix-gc          - Collect Nix garbage"
	@echo "  flake-update    - Update flake inputs"
	@echo "  flake-check     - Check the flake for errors"

env:
	@if [ -z "$(HOST)" ]; then \
		echo "HOST is not set"; \
		exit 1; \
	fi

setup: env
	@export EDITOR=vim
	@nix shell nixpkgs#vim

disko: env
	sudo nix $(NIX_FLAGS) run github:nix-community/disko/latest -- --mode destroy,format,mount --flake $(FLAKE)
	sudo nixos-generate-config --no-filesystems --root /mnt --dir $(DIR)
	@lsblk

nixos-install: env
	sudo nixos-install --no-channel-copy --no-root-password --flake $(FLAKE) --root /mnt
	@sudo ln -s $(DIR) /mnt/etc/nixos

nixos-rebuild: env
	@sudo nixos-rebuild switch --flake $(FLAKE)

nix-gc: env
	@sudo nix-collect-garbage -d

flake-update: env
	@nix $(NIX_FLAGS) flake update

flake-check: env
	@nix $(NIX_FLAGS) flake check
