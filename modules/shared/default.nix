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
    # Core utilities
    curl
    wget
    git
    vim
    neovim
    htop

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
      # Allow build-time CPU offloading
      builders-use-substitutes = true;
      # Trust users to add to nix store
      trusted-users = [ "root" "@wheel" "@admin" ];
    };
    # Garbage collection
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };
}
