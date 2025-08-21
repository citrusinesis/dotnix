{ config, lib, pkgs, ... }:

{
  # MangoHud for gaming performance monitoring
  home.packages = with pkgs; [
    mangohud
    goverlay  # GUI for MangoHud configuration
  ];

  # MangoHud configuration
  home.file.".config/MangoHud/MangoHud.conf" = {
    text = ''
      # MangoHud Configuration for Gaming
      
      ################ DISPLAY SETTINGS ################
      
      # HUD position (top-left, top-right, middle-left, middle-right, bottom-left, bottom-right, top-center, bottom-center)
      position=top-left
      
      # HUD size
      font_size=24
      
      # Background settings
      background_alpha=0.5
      background_color=020202
      
      # Text colors
      text_color=FFFFFF
      
      ################ PERFORMANCE METRICS ################
      
      # CPU information
      cpu_stats
      cpu_temp
      cpu_load_change
      
      # GPU information  
      gpu_stats
      gpu_temp
      gpu_load_change
      gpu_core_clock
      gpu_mem_clock
      gpu_power
      
      # Memory information
      ram
      vram
      
      # System information
      fps
      frametime
      frame_timing
      
      # Process information
      procmem
      
      ################ PERFORMANCE LIMITS ################
      
      # FPS limit (0 = unlimited)
      fps_limit=0
      
      # Toggle FPS limit key
      toggle_fps_limit=Shift_L+F1
      
      ################ LOGGING ################
      
      # Enable logging
      output_folder=/home/game/Documents/MangoHud
      
      # Log file format
      log_duration=0
      autostart_log=0
      log_interval=100
      
      # Toggle logging key
      toggle_logging=Shift_L+F2
      
      ################ DISPLAY TOGGLES ################
      
      # Toggle HUD visibility
      toggle_hud=Shift_R+F12
      
      # Toggle detailed view
      toggle_detailed=Shift_L+F12
      
      ################ WINE/PROTON SPECIFIC ################
      
      # Wine/Proton settings
      wine
      wine_color=eb5f5f
      
      ################ VULKAN SPECIFIC ################
      
      # Vulkan settings
      vulkan_driver
      
      ################ OPENGL SPECIFIC ################
      
      # OpenGL settings
      gl_vsync=0
      
      ################ ADVANCED SETTINGS ################
      
      # Update interval (milliseconds)
      fps_sampling_period=500
      
      # Graph settings
      histogram
      
      # Battery info (for laptops)
      battery
      battery_color=ff9078
      
      # Gamepad info
      gamepad_battery
      gamepad_battery_icon
      
      # Network info
      network
      
      # Disk usage
      io_read
      io_write
      
      # Custom text
      custom_text=Gaming Session
      
      ################ PRESETS ################
      
      # You can create different presets for different games
      # Uncomment and modify as needed:
      
      # Minimal preset - just FPS
      #preset=1,fps
      
      # Standard preset - FPS, CPU, GPU basics
      #preset=2,fps,cpu_stats,gpu_stats,ram,vram
      
      # Detailed preset - everything
      #preset=3,fps,cpu_stats,cpu_temp,gpu_stats,gpu_temp,ram,vram,frametime
    '';
  };

  # MangoHud environment configuration
  home.sessionVariables = {
    # Enable MangoHud for Vulkan applications
    MANGOHUD = "1";
    
    # MangoHud configuration file location
    MANGOHUD_CONFIG = "${config.home.homeDirectory}/.config/MangoHud/MangoHud.conf";
    
    # MangoHud log location
    MANGOHUD_OUTPUT = "${config.home.homeDirectory}/Documents/MangoHud";
  };

  # Scripts for MangoHud management
  home.file = {
    ".local/bin/mangohud-preset" = {
      executable = true;
      text = ''
        #!/bin/bash
        # MangoHud preset switcher
        
        CONFIG_FILE="$HOME/.config/MangoHud/MangoHud.conf"
        BACKUP_DIR="$HOME/.config/MangoHud/presets"
        
        mkdir -p "$BACKUP_DIR"
        
        case "$1" in
          minimal)
            echo "Switching to minimal preset (FPS only)..."
            cat > "$CONFIG_FILE" << EOF
        position=top-left
        font_size=24
        background_alpha=0.3
        fps
        toggle_hud=Shift_R+F12
        EOF
            ;;
            
          standard)
            echo "Switching to standard preset (FPS, CPU, GPU)..."
            cat > "$CONFIG_FILE" << EOF
        position=top-left
        font_size=24
        background_alpha=0.4
        fps
        cpu_stats
        cpu_temp
        gpu_stats
        gpu_temp
        ram
        vram
        toggle_hud=Shift_R+F12
        toggle_detailed=Shift_L+F12
        EOF
            ;;
            
          detailed)
            echo "Switching to detailed preset (everything)..."
            cp "$HOME/.config/MangoHud/MangoHud.conf.full" "$CONFIG_FILE" 2>/dev/null || {
              echo "Full configuration not found, using standard preset"
              $0 standard
              return
            }
            ;;
            
          benchmark)
            echo "Switching to benchmark preset..."
            cat > "$CONFIG_FILE" << EOF
        position=top-left
        font_size=22
        background_alpha=0.6
        fps
        frametime
        frame_timing=1
        cpu_stats
        cpu_temp
        cpu_load_change
        gpu_stats
        gpu_temp
        gpu_load_change
        gpu_core_clock
        gpu_mem_clock
        ram
        vram
        histogram
        log_duration=60
        output_folder=$HOME/Documents/MangoHud
        toggle_hud=Shift_R+F12
        toggle_logging=Shift_L+F2
        EOF
            ;;
            
          backup)
            echo "Backing up current configuration..."
            cp "$CONFIG_FILE" "$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).conf"
            echo "Configuration backed up to $BACKUP_DIR/"
            ;;
            
          list)
            echo "Available presets:"
            echo "  minimal   - FPS only"
            echo "  standard  - FPS, CPU, GPU basics"
            echo "  detailed  - All available metrics"
            echo "  benchmark - Detailed with logging for benchmarking"
            echo "  backup    - Backup current configuration"
            echo ""
            echo "Available backups:"
            ls -la "$BACKUP_DIR" 2>/dev/null | grep -v "^total" | grep -v "^d" || echo "  No backups found"
            ;;
            
          *)
            echo "Usage: $0 [minimal|standard|detailed|benchmark|backup|list]"
            echo ""
            echo "Current configuration:"
            head -20 "$CONFIG_FILE" 2>/dev/null || echo "Configuration file not found"
            ;;
        esac
      '';
    };

    ".local/bin/mangohud-log-analyzer" = {
      executable = true;
      text = ''
        #!/bin/bash
        # MangoHud log analyzer
        
        LOG_DIR="$HOME/Documents/MangoHud"
        
        if [ ! -d "$LOG_DIR" ]; then
          echo "MangoHud log directory not found: $LOG_DIR"
          exit 1
        fi
        
        if [ "$1" = "latest" ]; then
          LATEST_LOG=$(ls -t "$LOG_DIR"/*.csv 2>/dev/null | head -1)
          if [ -z "$LATEST_LOG" ]; then
            echo "No log files found in $LOG_DIR"
            exit 1
          fi
          echo "Analyzing latest log: $LATEST_LOG"
          LOG_FILE="$LATEST_LOG"
        elif [ -f "$1" ]; then
          LOG_FILE="$1"
        else
          echo "Available log files:"
          ls -la "$LOG_DIR"/*.csv 2>/dev/null || echo "No log files found"
          echo ""
          echo "Usage: $0 [latest|/path/to/logfile.csv]"
          exit 1
        fi
        
        echo "=== MangoHud Log Analysis ==="
        echo "File: $LOG_FILE"
        echo ""
        
        # Check if the file has data
        if [ ! -s "$LOG_FILE" ]; then
          echo "Log file is empty"
          exit 1
        fi
        
        # Basic statistics using awk
        awk -F',' '
        BEGIN { 
          min_fps = 999999; max_fps = 0; sum_fps = 0; count = 0;
          min_cpu = 999999; max_cpu = 0; sum_cpu = 0;
          min_gpu = 999999; max_gpu = 0; sum_gpu = 0;
        }
        NR > 1 && $2 != "" { 
          fps = $2; cpu_usage = $3; gpu_usage = $4;
          
          if (fps > 0) {
            if (fps < min_fps) min_fps = fps;
            if (fps > max_fps) max_fps = fps;
            sum_fps += fps;
          }
          
          if (cpu_usage > 0) {
            if (cpu_usage < min_cpu) min_cpu = cpu_usage;
            if (cpu_usage > max_cpu) max_cpu = cpu_usage;
            sum_cpu += cpu_usage;
          }
          
          if (gpu_usage > 0) {
            if (gpu_usage < min_gpu) min_gpu = gpu_usage;
            if (gpu_usage > max_gpu) max_gpu = gpu_usage;
            sum_gpu += gpu_usage;
          }
          
          count++;
        }
        END {
          if (count > 0) {
            printf "FPS Statistics:\n";
            printf "  Average: %.2f\n", sum_fps/count;
            printf "  Minimum: %.2f\n", min_fps;
            printf "  Maximum: %.2f\n", max_fps;
            printf "\n";
            printf "CPU Usage Statistics:\n";
            printf "  Average: %.2f%%\n", sum_cpu/count;
            printf "  Minimum: %.2f%%\n", min_cpu;
            printf "  Maximum: %.2f%%\n", max_cpu;
            printf "\n";
            printf "GPU Usage Statistics:\n";
            printf "  Average: %.2f%%\n", sum_gpu/count;
            printf "  Minimum: %.2f%%\n", min_gpu;
            printf "  Maximum: %.2f%%\n", max_gpu;
            printf "\n";
            printf "Total samples: %d\n", count;
          } else {
            printf "No valid data found in log file\n";
          }
        }' "$LOG_FILE"
      '';
    };
  };

  # Desktop entries for MangoHud utilities
  xdg.desktopEntries = {
    goverlay = {
      name = "GOverlay";
      comment = "Graphical MangoHud configuration tool";
      exec = "goverlay";
      icon = "goverlay";
      categories = [ "Game" "Settings" ];
    };
    
    mangohud-presets = {
      name = "MangoHud Presets";
      comment = "Switch MangoHud display presets";
      exec = "kitty -e ${config.home.homeDirectory}/.local/bin/mangohud-preset list";
      icon = "preferences-system-performance";
      categories = [ "Game" "Settings" ];
    };
    
    mangohud-logs = {
      name = "MangoHud Log Analyzer";
      comment = "Analyze MangoHud performance logs";
      exec = "kitty -e ${config.home.homeDirectory}/.local/bin/mangohud-log-analyzer latest";
      icon = "utilities-system-monitor";
      categories = [ "System" "Monitor" ];
    };
  };

  # Create MangoHud log directory
  home.file."Documents/MangoHud/.keep".text = "";

  # Shell aliases for MangoHud
  programs.bash.shellAliases = {
    mh-minimal = "${config.home.homeDirectory}/.local/bin/mangohud-preset minimal";
    mh-standard = "${config.home.homeDirectory}/.local/bin/mangohud-preset standard";
    mh-detailed = "${config.home.homeDirectory}/.local/bin/mangohud-preset detailed";
    mh-benchmark = "${config.home.homeDirectory}/.local/bin/mangohud-preset benchmark";
    mh-logs = "${config.home.homeDirectory}/.local/bin/mangohud-log-analyzer latest";
  };
}