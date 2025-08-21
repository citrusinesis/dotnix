{ config, lib, pkgs, inputs, username, ... }:

{
  # Import modular program configurations
  imports = [
    ./programs
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = lib.mkDefault "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Gaming-focused packages
  home.packages = with pkgs; [
    # Gaming platforms
    steam
    lutris
    heroic
    bottles
    
    # Gaming utilities
    gamemode
    gamescope
    mangohud
    goverlay
    
    # Performance monitoring
    htop
    btop
    nvtop
    
    # Communication
    discord
    teamspeak_client
    
    # Media and streaming
    obs-studio
    vlc
    
    # File management
    file-roller
    
    # Browsers optimized for gaming
    firefox
    google-chrome
    
    # System utilities
    pciutils
    usbutils
    lshw
    
    # Audio tools
    pavucontrol
    pulseaudio
    
    # Network tools
    speedtest-cli
  ];

  # Gaming-specific configurations
  programs = {
    # Gaming-optimized terminal
    kitty = {
      enable = true;
      settings = {
        font_family = "GeistMono NF";
        font_size = 12;
        background_opacity = "0.9";
        
        # Gaming-friendly colors
        foreground = "#ffffff";
        background = "#1a1a1a";
        
        # Performance settings
        sync_to_monitor = true;
        disable_ligatures = "cursor";
      };
    };

    # Basic shell for gaming user
    bash = {
      enable = true;
      bashrcExtra = ''
        # Gaming-specific aliases
        alias steam-native="steam -native"
        alias steam-runtime="steam"
        alias gamemode="gamemoderun"
        
        # Performance aliases
        alias cpu-performance="sudo cpupower frequency-set -g performance"
        alias cpu-powersave="sudo cpupower frequency-set -g powersave"
        
        # GPU monitoring
        alias gpu-status="nvidia-smi"
        alias gpu-temp="nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits"
      '';
    };

    # Git configuration for gaming user
    git = {
      enable = true;
      userName = "Game User";
      userEmail = "game@localhost";
    };
  };

  # XDG directories for gaming
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      videos = "$HOME/Videos";
      # Custom gaming directories
      extraConfig = {
        XDG_GAMES_DIR = "$HOME/Games";
        XDG_GAMEDATA_DIR = "$HOME/.local/share/games";
      };
    };
  };

  # Gaming-specific services
  services = {
    # Gaming performance daemon
    gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 10;
          ioprio = 0;
          inhibit_screensaver = 1;
          softrealtime = "auto";
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
        };
      };
    };
  };

  # Gaming-specific environment variables
  home.sessionVariables = {
    # Steam
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    
    # Gaming performance
    __GL_THREADED_OPTIMIZATIONS = "1";
    __GL_SHADER_DISK_CACHE = "1";
    __GL_SHADER_DISK_CACHE_PATH = "$HOME/.cache/nvidia";
    
    # Vulkan
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";
    
    # Gaming-specific paths
    GAMES_DIR = "/mnt/games";
    STEAM_LIBRARY = "/mnt/games/SteamLibrary";
  };

  # Create gaming directories
  home.file = {
    # Steam library configuration
    ".steam/steam/steamapps/libraryfolders.vdf" = {
      text = ''
        "libraryfolders"
        {
          "0"
          {
            "path"		"/home/game/.steam/steam"
            "label"		""
            "mounted"		"1"
            "contentid"		"0"
          }
          "1"
          {
            "path"		"/mnt/games/SteamLibrary"
            "label"		"Games Drive"
            "mounted"		"1"
            "contentid"		"1"
          }
        }
      '';
    };
    
    # GameMode configuration
    ".config/gamemode.ini" = {
      text = ''
        [general]
        renice=10
        ioprio=0
        inhibit_screensaver=1
        softrealtime=auto

        [gpu]
        apply_gpu_optimisations=accept-responsibility
        gpu_device=0

        [cpu]
        park_cores=no
        pin_cores=no

        [custom]
        start=notify-send "GameMode started"
        end=notify-send "GameMode ended"
      '';
    };
  };
}