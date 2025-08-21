{ config, pkgs, lib, ... }:

{
  # Import all Darwin-specific modules
  imports = [
    ./homebrew.nix
    ./system-defaults.nix
    # Add other Darwin-specific module imports here as needed
  ];

  # Common Darwin system configuration

  # Set default time zone
  time.timeZone = lib.mkDefault "UTC";

  # Environment variables are defined in shared module

  # System packages are defined in shared module

  # Enable user shells
  programs.zsh.enable = true;
  programs.bash.enable = true;

  # Additional Darwin-specific font configuration
  fonts = {
    # Shared fonts are defined in shared module
  };
}
