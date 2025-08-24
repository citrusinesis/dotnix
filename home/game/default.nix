{ config, lib, pkgs, inputs, username ? "game", nixpkgs-unstable, ... }:

let
  # Import unstable packages with unfree support
  unstable = import nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
    };
  };
in
{
  # Import modular program configurations
  imports = [
    ./programs
  ];

  # Configure nixpkgs for home-manager with unfree support
  nixpkgs.config = {
    allowUnfree = true;
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "game";
  home.homeDirectory = "/home/game";

  # This value determines the Home Manager release that your configuration is
  # compatible with.
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Gaming-focused packages
  home.packages = with pkgs; [
    # Essential utilities
    neovim
    git
    curl
    wget
    
    # Gaming communication
    discord
    teamspeak_client
    
    # Gaming tools and launchers (only available to game user)
    steam
    heroic
    lutris
    bottles
    gamescope
    mangohud
    goverlay
    
    # Game streaming and recording (only available to game user)
    obs-studio
    audacity
    
    # Performance monitoring
    btop
    nvtopPackages.nvidia
    
    # File management
    file-roller
    
    # Web browser for gaming needs
    unstable.firefox
    
    # Gaming peripherals support
    piper
    solaar
    
    # Network tools
    speedtest-cli
  ];

  # Gaming-specific environment variables
  home.sessionVariables = {
    # Steam optimizations
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    
    # NVIDIA optimizations
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
    
    # Gaming performance
    MANGOHUD = "1";
    DXVK_HUD = "fps";
  };

  # Gaming-optimized shell aliases
  home.shellAliases = {
    # Steam shortcuts
    steam-native = "steam -native";
    steam-big = "steam -bigpicture";
    
    # Gaming performance
    gamemode-status = "gamemoded -s";
    gpu-temp = "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits";
    
    # System monitoring
    gpu = "nvtop";
    temps = "watch -n 1 'sensors; nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits'";
    
    # Quick launches
    heroic-launcher = "heroic";
    lutris-launcher = "lutris";
  };
}