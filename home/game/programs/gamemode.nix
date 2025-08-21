{ config, lib, pkgs, ... }:

{
  # GameMode configuration for optimal gaming performance
  home.packages = with pkgs; [
    gamemode
    gamescope
  ];

  # GameMode user configuration
  home.file.".config/gamemode.ini" = {
    text = ''
      [general]
      ; The renice priority for all clients, or -1 to disable
      renice=10

      ; The ioprio class for all clients (0-3), or -1 to disable
      ; 0 = rt, 1 = be, 2 = idle, 3 = none
      ioprio=0

      ; The ionice priority for all clients (0-7), or -1 to disable
      ionice=0

      ; The desired nice value for the game process
      desiredgov=performance

      ; The governor to switch to when the game is running
      ; Options: performance, powersave, userspace, ondemand, conservative, schedutil
      governor=performance

      ; Disable windows key during gaming
      inhibit_screensaver=1

      ; GameScope integration
      softrealtime=auto

      [gpu]
      ; Apply GPU optimizations
      ; WARNING: This may damage your GPU if set incorrectly
      apply_gpu_optimisations=accept-responsibility

      ; GPU device to apply optimizations to (usually 0)
      gpu_device=0

      ; AMD GPU performance level (low, auto, high)
      amd_performance_level=high

      ; NVIDIA GPU power mode (0=adaptive, 1=prefer maximum performance)
      nv_powermizer_mode=1

      [cpu]
      ; Park CPU cores
      park_cores=no

      ; Pin client to specific cores
      pin_cores=no

      ; CPU frequency scaling governor
      gov_on_battery=powersave

      [custom]
      ; Commands to be executed on game start
      start=notify-send "GameMode activated" "Game performance optimizations enabled"

      ; Commands to be executed on game end  
      end=notify-send "GameMode deactivated" "Game performance optimizations disabled"

      ; Maximum number of clients that can register
      max_clients=1

      ; Timeout for game detection
      timeout=5

      ; Log level (0=silent, 1=error, 2=warning, 3=info, 4=debug)
      log_level=2
    '';
  };

  # GameScope configuration
  home.file.".config/gamescope/gamescope.conf" = {
    text = ''
      # GameScope configuration
      # Gaming-focused compositor for improved performance
      
      # Display settings
      width=1920
      height=1080
      refresh=60
      
      # Performance settings
      force-composition=true
      adaptive-sync=true
      
      # Steam integration
      steam-integration=true
      
      # Input settings
      grab-cursor=true
      hide-cursor-delay=3000
      
      # Filtering
      filter=linear
      
      # HDR settings (if supported)
      hdr-enabled=false
      hdr-debug-force-output=false
    '';
  };

  # Gaming performance scripts
  home.file = {
    ".local/bin/gamemode-status" = {
      executable = true;
      text = ''
        #!/bin/bash
        # Check GameMode status
        
        if pgrep -x "gamemode" > /dev/null; then
          echo "GameMode is running"
          gamemoded -s
        else
          echo "GameMode is not running"
        fi
        
        echo
        echo "=== CPU Governor ==="
        cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "Unable to read CPU governor"
        
        echo
        echo "=== Active Games ==="
        gamemoded -l 2>/dev/null || echo "No active games detected"
      '';
    };

    ".local/bin/gaming-performance" = {
      executable = true;
      text = ''
        #!/bin/bash
        # Manual gaming performance toggle
        
        if [ "$1" = "on" ]; then
          echo "Enabling gaming performance mode..."
          
          # CPU Governor
          sudo cpupower frequency-set -g performance 2>/dev/null || echo "Could not set CPU governor"
          
          # GPU Performance (NVIDIA)
          if command -v nvidia-settings >/dev/null 2>&1; then
            nvidia-settings -a '[gpu:0]/GpuPowerMizerMode=1' >/dev/null 2>&1 || echo "Could not set GPU performance mode"
          fi
          
          # Kernel tweaks
          echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled >/dev/null 2>&1 || true
          echo 1 | sudo tee /sys/kernel/mm/transparent_hugepage/defrag >/dev/null 2>&1 || true
          
          # I/O Scheduler
          for disk in /sys/block/sd*/queue/scheduler; do
            if [ -f "$disk" ]; then
              echo mq-deadline | sudo tee "$disk" >/dev/null 2>&1 || true
            fi
          done
          
          echo "Gaming performance mode enabled"
          
        elif [ "$1" = "off" ]; then
          echo "Disabling gaming performance mode..."
          
          # CPU Governor
          sudo cpupower frequency-set -g powersave 2>/dev/null || echo "Could not reset CPU governor"
          
          # GPU Performance (NVIDIA)
          if command -v nvidia-settings >/dev/null 2>&1; then
            nvidia-settings -a '[gpu:0]/GpuPowerMizerMode=0' >/dev/null 2>&1 || echo "Could not reset GPU performance mode"
          fi
          
          # Reset kernel tweaks
          echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled >/dev/null 2>&1 || true
          echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/defrag >/dev/null 2>&1 || true
          
          echo "Gaming performance mode disabled"
          
        else
          echo "Usage: $0 [on|off]"
          echo "  on  - Enable gaming performance optimizations"
          echo "  off - Disable gaming performance optimizations"
          exit 1
        fi
      '';
    };
  };

  # Desktop entries for GameMode utilities
  xdg.desktopEntries = {
    gamemode-status = {
      name = "GameMode Status";
      comment = "Check GameMode status and performance settings";
      exec = "kitty -e ${config.home.homeDirectory}/.local/bin/gamemode-status";
      icon = "applications-games";
      categories = [ "System" "Monitor" ];
    };
    
    gaming-performance-on = {
      name = "Enable Gaming Mode";
      comment = "Enable gaming performance optimizations";
      exec = "kitty -e ${config.home.homeDirectory}/.local/bin/gaming-performance on";
      icon = "applications-games";
      categories = [ "System" "Settings" ];
    };
    
    gaming-performance-off = {
      name = "Disable Gaming Mode";
      comment = "Disable gaming performance optimizations";
      exec = "kitty -e ${config.home.homeDirectory}/.local/bin/gaming-performance off";
      icon = "applications-system";
      categories = [ "System" "Settings" ];
    };
  };

  # Shell aliases for gaming
  programs.bash.shellAliases = {
    gamemode-on = "${config.home.homeDirectory}/.local/bin/gaming-performance on";
    gamemode-off = "${config.home.homeDirectory}/.local/bin/gaming-performance off";
    gamemode-status = "${config.home.homeDirectory}/.local/bin/gamemode-status";
  };
}