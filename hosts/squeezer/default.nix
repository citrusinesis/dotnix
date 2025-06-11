{ config, pkgs, lib, inputs, username, ... }:

{
  # Import modules
  imports = [
    ../../modules/shared
    ../../modules/darwin
  ];

  # Host-specific configuration for 'squeezer' macOS system
  networking.hostName = "squeezer";
  networking.knownNetworkServices = [ "Wi-Fi" "Ethernet" ];

  # Host-specific homebrew casks
  homebrew.casks = [
    # Browser
    "google-chrome"
    "firefox"

    # Development Tools
    "jetbrains-toolbox"
    "visual-studio-code"
    "figma"
    "warp"

    # VPN
    "tailscale"

    # Productivity Tools
    "slack"
    "notion"
    "obsidian"
    "raycast"
    "heynote"
  ];

  # Machine-specific system defaults
  system.defaults.finder = {
    ShowExternalHardDrivesOnDesktop = true;
    ShowHardDrivesOnDesktop = false;
    ShowMountedServersOnDesktop = true;
    ShowRemovableMediaOnDesktop = true;
  };

  # Configure user account
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  # Add machine-specific packages
  environment.systemPackages = with pkgs; [
    # Development tools
    nodejs
    python3
    go

    # System utilities
    coreutils
    gnupg

    # Terminal utilities
    tmux
    neovim
  ];
}
