{ config, pkgs, lib, ... }:

{
  # Configure homebrew
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = [
      "homebrew/cask"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/core"
    ];
    
    # CLI applications
    brews = [
      # Add CLI applications from homebrew
      # Examples:
      # "mas" # Mac App Store CLI
      # "svn" # Subversion
    ];
    
    # GUI applications
    casks = [
      # Add macOS applications from homebrew
      "firefox"
      # Examples:
      # "1password"
      # "alfred"
      # "discord"
      # "docker"
      # "iterm2"
      # "slack"
      # "visual-studio-code"
    ];
    
    # Mac App Store applications
    # Requires the mas CLI tool (brew install mas)
    masApps = {
      # Format: "App Name" = app_id;
      # Examples:
      # "Xcode" = 497799835;
      # "Keynote" = 409183694;
      # "Numbers" = 409203825;
      # "Pages" = 409201541;
    };
  };
}