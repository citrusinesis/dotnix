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
    
    # CLI applications (add as needed)
    brews = [];
    
    # GUI applications (defined in individual hosts)
    casks = [];
    
    # Mac App Store applications (add as needed)
    masApps = {};
  };
}