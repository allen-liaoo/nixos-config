{ pkgs, lib, config, inputs, aln, ... }:

{
  nix = {
    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
        "pipe-operators"
      ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
    };
    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
      dates = lib.mkDefault "weekly";
      persistent = true;
    };
    # Below snippets make channels use flake inputs
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  environment.systemPackages = with pkgs; [
    curl
    dig             # in: dnsutils or bind 
    git
    home-manager
    iproute2        # ip, ss
    iputils         # ping, tracepath
    just
    lsof
    nmap
    pciutils
    procps          # ps, top
    tcpdump
    traceroute
    vim
    wget
    whois
    unzip
    util-linux
    zip
  ];

  networking.hostName = aln.ctx.host.name;

  users.mutableUsers = false;
  security.sudo.extraConfig = ''
    Defaults pwfeedback # typed password visible as asterisks
    Defaults lecture = never # dont display warning
    Defaults timestamp_timeout=15 # only ask for password every 15min
  '';

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
