# This file contains modules that are shared between NixOS and Darwin
{ config, pkgs, lib, ... }:

{
  # Basic environment setup - works on both systems
  environment.shellAliases = {
    ls = "ls --color=auto";
    ll = "ls -la";
    grep = "grep --color=auto";
    g = "git";
  };

  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  # Shared system packages for all systems
  environment.systemPackages = with pkgs; [
    # Core utilities (git managed by home-manager)
    curl
    wget
    htop

    # Editors (vim as fallback, neovim managed by users)
    vim

    # Development tools
    gnumake
    gcc

    # Archive tools
    zip
    unzip
  ];

  # Nix configuration - works on both NixOS and Darwin
  nix = {
    optimise.automatic = true;
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = [ "nix-command" "flakes" ];
      
      # Performance optimizations
      builders-use-substitutes = true;
      max-jobs = "auto";
      cores = 0; # Use all available cores
      
      # Additional substituters for faster builds
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      
      # Trust users to add to nix store
      trusted-users = [ "root" "@wheel" "@admin" ];
      
      # Build optimization
      auto-optimise-store = true;
    };
    
    # Improved garbage collection
    gc = {
      automatic = true;
      options = "--delete-older-than 14d"; # More frequent cleanup
    };
  };

  nixpkgs.config.allowUnfree = true;

  # Shared font configuration for all systems
  fonts.packages = with pkgs; [
    # Nerd fonts for both platforms
    nerd-fonts.geist-mono
    nerd-fonts.d2coding
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];
}
