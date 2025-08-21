{ config, pkgs, lib, username, ... }:

{
  # Gaming-specific system configuration for NixOS
  
  # Enable 32-bit support for Steam and games
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Gaming-specific kernel parameters
  boot.kernel.sysctl = {
    # Virtual memory tweaks for gaming
    "vm.max_map_count" = 2147483642;  # Required for some games
    "vm.swappiness" = 10;             # Reduce swap usage
    "vm.vfs_cache_pressure" = 50;     # Balance file cache pressure
    
    # Network optimizations for gaming
    "net.core.rmem_default" = 262144;
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_default" = 262144;
    "net.core.wmem_max" = 134217728;
    "net.core.netdev_max_backlog" = 5000;
    
    # TCP optimizations
    "net.ipv4.tcp_rmem" = "4096 65536 134217728";
    "net.ipv4.tcp_wmem" = "4096 65536 134217728";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_slow_start_after_idle" = 0;
  };

  # Gaming kernel modules
  boot.kernelModules = [ 
    "uinput"      # For virtual input devices
    "v4l2loopback" # For streaming/recording
  ];

  # Gaming-specific services
  services = {
    # Enable GameMode system daemon
    gamemode = {
      enable = true;
      enableRenice = true;
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
          nv_powermizer_mode = 1;
        };
        cpu = {
          park_cores = "no";
          pin_cores = "no";
        };
      };
    };

    # Pipewire low-latency for gaming audio
    pipewire = {
      extraConfig.pipewire = {
        "92-low-latency" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 32;
            "default.clock.min-quantum" = 32;
            "default.clock.max-quantum" = 32;
          };
        };
      };
    };

    # Disable power management for gaming peripherals
    udev.extraRules = ''
      # Gaming mice and keyboards - disable power management
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{power/control}="on"  # Logitech
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1532", ATTR{power/control}="on"  # Razer
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0738", ATTR{power/control}="on"  # Mad Catz
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1038", ATTR{power/control}="on"  # SteelSeries
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1b1c", ATTR{power/control}="on"  # Corsair
      
      # Set scheduler for gaming drives
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"
      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
    '';
  };

  # Gaming-specific user groups and permissions
  users.groups = {
    gamemode = {};
    games = {};
  };

  # System-wide gaming packages
  environment.systemPackages = with pkgs; [
    # Core gaming platforms
    steam
    lutris
    heroic
    bottles
    
    # Gaming utilities
    gamemode
    gamescope
    mangohud
    goverlay
    
    # Proton utilities
    protontricks
    protonup-qt
    
    # Performance monitoring
    nvtop
    intel-gpu-tools
    
    # Streaming and recording
    obs-studio
    ffmpeg
    
    # Game development tools
    steamcmd
    steam-run
    
    # Wine and compatibility
    wine
    winetricks
    dxvk
    
    # Controllers and input
    antimicrox
    qjoypad
    
    # System utilities for gaming
    pciutils
    usbutils
    lshw
    stress-ng
    
    # Audio utilities
    pavucontrol
    pulseaudio
    alsa-utils
  ];

  # Gaming environment variables
  environment.sessionVariables = {
    # Steam
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${username}/.steam/root/compatibilitytools.d";
    
    # Performance
    __GL_THREADED_OPTIMIZATIONS = "1";
    __GL_SHADER_DISK_CACHE = "1";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    
    # Vulkan
    VK_INSTANCE_LAYERS = "VK_LAYER_MESA_overlay:VK_LAYER_MANGOHUD_overlay";
    
    # Wine
    WINEPREFIX = "/home/${username}/.wine";
    WINEARCH = "win64";
    
    # Gaming-specific
    MANGOHUD = "1";
    PROTON_ENABLE_NVAPI = "1";
    PROTON_ENABLE_NGX_UPDATER = "1";
    PROTON_HIDE_NVIDIA_GPU = "0";
    PROTON_NO_ESYNC = "0";
    PROTON_NO_FSYNC = "0";
    PROTON_FORCE_LARGE_ADDRESS_AWARE = "1";
  };

  # Gaming-specific programs configuration
  programs = {
    # Enable Steam system-wide
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    # GameMode configuration
    gamemode.enable = true;
    
    # Enable dconf for some gaming applications
    dconf.enable = true;
  };

  # Security settings for gaming
  security = {
    # Allow GameMode to set real-time priority
    wrappers = {
      gamemode = {
        owner = "root";
        group = "gamemode";
        source = "${pkgs.gamemode}/bin/gamemoderun";
        capabilities = "cap_sys_nice+ep";
      };
    };
    
    # PAM limits for gaming performance
    pam.loginLimits = [
      {
        domain = "@gamemode";
        type = "soft";
        item = "nice";
        value = "-10";
      }
      {
        domain = "@gamemode";
        type = "hard";
        item = "nice";
        value = "-10";
      }
      {
        domain = "@gamemode";
        type = "soft";
        item = "rtprio";
        value = "20";
      }
      {
        domain = "@gamemode";
        type = "hard";
        item = "rtprio";
        value = "20";
      }
    ];
  };

  # Networking optimizations for gaming
  networking = {
    firewall = {
      allowedTCPPorts = [
        # Steam
        27036 27037
        # Steam Remote Play
        27031 27032 27033 27034 27035
      ];
      allowedUDPPorts = [
        # Steam
        27031 27032 27033 27034 27035 27036
        # Steam Voice Chat
        3478 4379 4380
      ];
    };
  };

  # Font configuration for gaming
  fonts.packages = with pkgs; [
    # Gaming-friendly fonts
    liberation_ttf
    dejavu_fonts
    source-han-sans
    source-han-serif
    
    # Emoji support for gaming chat
    noto-fonts-emoji
    twitter-color-emoji
  ];

  # Gaming-specific systemd services
  systemd.services = {
    # Optimize system for gaming on boot
    gaming-optimization = {
      description = "Apply gaming-specific system optimizations";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        # Set I/O scheduler for storage devices
        for dev in /sys/block/sd*/queue/scheduler; do
          [ -f "$dev" ] && echo mq-deadline > "$dev" 2>/dev/null || true
        done
        
        for dev in /sys/block/nvme*/queue/scheduler; do
          [ -f "$dev" ] && echo none > "$dev" 2>/dev/null || true
        done
        
        # Disable transparent huge pages for better gaming performance
        echo never > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || true
        echo never > /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null || true
        
        # Set vm.dirty ratios for gaming
        echo 15 > /proc/sys/vm/dirty_ratio 2>/dev/null || true
        echo 5 > /proc/sys/vm/dirty_background_ratio 2>/dev/null || true
      '';
    };
  };

  # Power management optimization for gaming
  powerManagement = {
    cpuFreqGovernor = lib.mkDefault "performance";
    scsiLinkPolicy = lib.mkDefault "max_performance";
  };

  # Hardware-specific gaming optimizations
  hardware = {
    # Enable all firmware
    enableRedistributableFirmware = true;
    
    # Gaming audio optimization
    pulseaudio = {
      support32Bit = true;
      extraConfig = ''
        # Gaming audio optimizations
        load-module module-udev-detect tsched=0
        load-module module-native-protocol-unix auth-anonymous=1 socket=/tmp/pulse-socket
      '';
    };
  };

  # Gaming-specific file system optimizations
  fileSystems = {
    # Optimize /tmp for gaming (if using tmpfs)
    "/tmp" = lib.mkIf (config.boot.tmp.useTmpfs) {
      options = [ "noatime" "size=8G" "mode=1777" ];
    };
  };
}