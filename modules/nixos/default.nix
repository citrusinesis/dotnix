# This file contains modules that are specific to NixOS
{ config, pkgs, lib, ... }:

{
  # Import all NixOS-specific modules
  imports = [
    # Add NixOS module imports here
    # Example: ./desktop.nix
    # Example: ./services.nix
    # Example: ./hardware.nix
  ];

  # Set default locale for NixOS
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  # Set default time zone
  time.timeZone = lib.mkDefault "UTC";

  # Common NixOS configuration that should apply to all NixOS systems

  # Enable NetworkManager for all NixOS systems
  networking.networkmanager.enable = lib.mkDefault true;

  # System-wide security settings
  security = {
    # Enable sudo
    sudo.enable = true;
    # Allow wheel group to use sudo
    sudo.wheelNeedsPassword = true;
    # Protect against fork bombs
    pam.loginLimits = [{
      domain = "*";
      type = "soft";
      item = "nproc";
      value = "unlimited";
    }];
  };

  # Enable basic system services
  services = {
    # Enable OpenSSH
    openssh = {
      enable = lib.mkDefault true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    # Enable NTP time synchronization
    timesyncd.enable = true;
  };

  # Configure default boot options
  boot = {
    # Clean temporary directories on boot
    tmp.cleanOnBoot = true;
    # Use the latest kernel
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };

  # Default power management settings
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "ondemand";
  };

  # System-wide program configurations
  programs = {
    # Enable command-not-found suggestions
    command-not-found.enable = true;
    # Bash shell configuration
    bash.completion.enable = true;
    # Zsh shell configuration
    zsh.enable = true;
  };

  # Default user configuration
  users.mutableUsers = lib.mkDefault true;

  # Default fonts configuration
  fonts = {
    fontDir = {
      enable = true;
      decompressFonts = true;
    };
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      
      nerd-fonts.geist-mono
      nerd-fonts.d2coding
      nerd-fonts.fira-code
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" "Liberation Serif" ];
        sansSerif = [ "Noto Sans" "Liberation Sans" ];
        monospace = [ "GeistMono NF" "Liberation Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
