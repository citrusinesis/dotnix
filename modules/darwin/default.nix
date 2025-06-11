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

  # Set environment variables
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  # Add system packages for all Darwin systems
  environment.systemPackages = with pkgs; [
    curl
    wget
    git
    vim
    htop
  ];

  # Enable user shells
  programs.zsh.enable = true;
  programs.bash.enable = true;

  # Configure fonts
  fonts = {
    packages = with pkgs; [
      nerd-fonts.geist-mono
      nerd-fonts.d2coding
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
    ];
  };
}
