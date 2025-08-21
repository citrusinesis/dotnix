{ config, lib, pkgs, ... }:

{
  # Steam configuration for gaming user
  home.packages = with pkgs; [
    steam
    steamcmd
    steam-run
    protontricks
    protonup-qt
  ];

  # Steam-specific environment variables
  home.sessionVariables = {
    # Enable Steam Play for all titles
    STEAM_COMPAT_DATA_PATH = "$HOME/.steam/steam/steamapps/compatdata";
    STEAM_COMPAT_TOOLS_PATH = "$HOME/.steam/root/compatibilitytools.d";
    
    # Proton configuration
    PROTON_ENABLE_NVAPI = "1";
    PROTON_ENABLE_NGX_UPDATER = "1";
    PROTON_HIDE_NVIDIA_GPU = "0";
    
    # Performance tweaks
    PROTON_NO_ESYNC = "0";
    PROTON_NO_FSYNC = "0";
    PROTON_FORCE_LARGE_ADDRESS_AWARE = "1";
    
    # Debugging (can be disabled for performance)
    # PROTON_LOG = "1";
    # DXVK_LOG_LEVEL = "info";
  };

  # Create Steam directories and configuration
  home.file = {
    # Steam launch options script
    ".local/bin/steam-gaming" = {
      executable = true;
      text = ''
        #!/bin/bash
        # Gaming-optimized Steam launcher
        
        # Set CPU governor to performance
        echo "Setting CPU to performance mode..."
        sudo cpupower frequency-set -g performance 2>/dev/null || echo "Could not set CPU governor"
        
        # Enable GameMode
        echo "Starting Steam with GameMode..."
        gamemoderun steam "$@"
        
        # Reset CPU governor when Steam closes
        echo "Resetting CPU to powersave mode..."
        sudo cpupower frequency-set -g powersave 2>/dev/null || echo "Could not reset CPU governor"
      '';
    };

    # Steam compatibility tools update script
    ".local/bin/update-proton" = {
      executable = true;
      text = ''
        #!/bin/bash
        # Update Proton compatibility tools
        
        COMPAT_DIR="$HOME/.steam/root/compatibilitytools.d"
        mkdir -p "$COMPAT_DIR"
        
        echo "Updating Proton compatibility tools..."
        
        # Download and install latest GE-Proton
        LATEST_GE=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
        if [ ! -z "$LATEST_GE" ]; then
          echo "Latest GE-Proton version: $LATEST_GE"
          if [ ! -d "$COMPAT_DIR/GE-Proton$LATEST_GE" ]; then
            echo "Downloading GE-Proton $LATEST_GE..."
            cd /tmp
            wget "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$LATEST_GE/GE-Proton$LATEST_GE.tar.gz"
            tar -xzf "GE-Proton$LATEST_GE.tar.gz" -C "$COMPAT_DIR"
            rm "GE-Proton$LATEST_GE.tar.gz"
            echo "GE-Proton $LATEST_GE installed successfully"
          else
            echo "GE-Proton $LATEST_GE already installed"
          fi
        fi
        
        echo "Proton tools update complete"
      '';
    };

    # Steam library management script
    ".local/bin/steam-library-info" = {
      executable = true;
      text = ''
        #!/bin/bash
        # Display Steam library information
        
        echo "=== Steam Library Information ==="
        echo
        
        # Main Steam directory
        STEAM_DIR="$HOME/.steam/steam/steamapps"
        if [ -d "$STEAM_DIR" ]; then
          echo "Main Steam Library: $STEAM_DIR"
          echo "Games installed: $(find "$STEAM_DIR/common" -maxdepth 1 -type d 2>/dev/null | wc -l)"
          echo "Disk usage: $(du -sh "$STEAM_DIR" 2>/dev/null | cut -f1)"
          echo
        fi
        
        # External game drive
        GAMES_DIR="/mnt/games/SteamLibrary"
        if [ -d "$GAMES_DIR" ]; then
          echo "External Game Library: $GAMES_DIR"
          echo "Games installed: $(find "$GAMES_DIR/steamapps/common" -maxdepth 1 -type d 2>/dev/null | wc -l)"
          echo "Disk usage: $(du -sh "$GAMES_DIR" 2>/dev/null | cut -f1)"
          echo "Available space: $(df -h "$GAMES_DIR" 2>/dev/null | tail -1 | awk '{print $4}')"
        else
          echo "External Game Library: Not mounted or not found at $GAMES_DIR"
        fi
        
        echo
        echo "=== Compatibility Tools ==="
        COMPAT_DIR="$HOME/.steam/root/compatibilitytools.d"
        if [ -d "$COMPAT_DIR" ]; then
          ls -la "$COMPAT_DIR" | grep -E '^d' | awk '{print $9}' | grep -v '^\.$' | grep -v '^\.\.$'
        else
          echo "No custom compatibility tools installed"
        fi
      '';
    };
  };

  # XDG desktop entries for Steam utilities
  xdg.desktopEntries = {
    steam-gaming = {
      name = "Steam (Gaming Mode)";
      comment = "Launch Steam with gaming optimizations";
      exec = "${config.home.homeDirectory}/.local/bin/steam-gaming";
      icon = "steam";
      categories = [ "Game" ];
    };
    
    update-proton = {
      name = "Update Proton Tools";
      comment = "Update Proton compatibility tools";
      exec = "kitty -e ${config.home.homeDirectory}/.local/bin/update-proton";
      icon = "system-software-update";
      categories = [ "System" "Settings" ];
    };
    
    steam-library-info = {
      name = "Steam Library Info";
      comment = "View Steam library information";
      exec = "kitty -e ${config.home.homeDirectory}/.local/bin/steam-library-info";
      icon = "folder-games";
      categories = [ "System" "FileManager" ];
    };
  };
}