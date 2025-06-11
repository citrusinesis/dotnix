{ config, lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;

    # Add general ssh configuration
    extraConfig = ''
      # Global options
      Host *
        AddKeysToAgent yes
        IdentitiesOnly yes
        ServerAliveInterval 60
        ServerAliveCountMax 30
        TCPKeepAlive yes
        Compression yes
        ControlMaster auto
        ControlPath ~/.ssh/control/%r@%h:%p
        ControlPersist 600
        StrictHostKeyChecking ask
        VerifyHostKeyDNS yes
        HashKnownHosts yes
        UserKnownHostsFile ~/.ssh/known_hosts

      # Include any local configs that aren't managed by Nix
      Include ~/.ssh/config.local
    '';
  };

  # Ensure SSH directory exists with proper permissions
  home.file.".ssh/.keep".text = "";
  home.activation.sshDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.ssh/control
    $DRY_RUN_CMD chmod 700 $VERBOSE_ARG ~/.ssh
    $DRY_RUN_CMD chmod 700 $VERBOSE_ARG ~/.ssh/control
  '';

  # SSH-related packages
  home.packages = with pkgs; [
    # SSH utilities
    ssh-audit      # Security audit tool for SSH
    sshpass        # Non-interactive ssh password auth
    ssh-copy-id    # Install SSH keys on a remote machine

    # For key management
    gnupg          # For GPG key management
    keychain       # Keychain to manage ssh-agent
  ];
}
