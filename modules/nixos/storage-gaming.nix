{ config, lib, pkgs, username, ... }:

{
  # Gaming storage configuration for /dev/sda
  # This module handles mounting and configuring additional storage for games
  
  options = {
    gaming.storage = {
      enable = lib.mkEnableOption "gaming storage configuration";
      
      device = lib.mkOption {
        type = lib.types.str;
        default = "/dev/sda";
        description = "Storage device for games";
      };
      
      mountPoint = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/games";
        description = "Mount point for games storage";
      };
      
      fileSystem = lib.mkOption {
        type = lib.types.str;
        default = "auto";
        description = "File system type (auto-detect by default)";
      };
      
      gameUser = lib.mkOption {
        type = lib.types.str;
        default = "game";
        description = "Gaming user account name";
      };
    };
  };

  config = lib.mkIf config.gaming.storage.enable {
    # Create mount point
    system.activationScripts.gaming-storage = {
      text = ''
        mkdir -p ${config.gaming.storage.mountPoint}
        chown root:games ${config.gaming.storage.mountPoint}
        chmod 755 ${config.gaming.storage.mountPoint}
      '';
      deps = [ "users" ];
    };

    # Mount configuration for games storage
    fileSystems.${config.gaming.storage.mountPoint} = {
      device = config.gaming.storage.device;
      fsType = config.gaming.storage.fileSystem;
      options = [
        "defaults"
        "noatime"           # Improve performance
        "user_xattr"        # Extended attributes for Steam
        "acl"              # Access control lists
        "rw"               # Read-write
        "exec"             # Allow executable files
        "auto"             # Auto-mount
        "users"            # Allow users to mount/unmount
      ];
      # Don't fail boot if the drive isn't connected
      noCheck = true;
    };

    # Create gaming directory structure after mount
    systemd.services.setup-gaming-storage = {
      description = "Setup gaming storage directory structure";
      after = [ "${lib.strings.replaceStrings ["/"] ["-"] config.gaming.storage.mountPoint}.mount" ];
      wants = [ "${lib.strings.replaceStrings ["/"] ["-"] config.gaming.storage.mountPoint}.mount" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
      };
      
      script = ''
        MOUNT_POINT="${config.gaming.storage.mountPoint}"
        GAME_USER="${config.gaming.storage.gameUser}"
        
        # Wait for mount to be available
        timeout=30
        while [ $timeout -gt 0 ] && ! mountpoint -q "$MOUNT_POINT"; do
          echo "Waiting for $MOUNT_POINT to be mounted..."
          sleep 1
          timeout=$((timeout - 1))
        done
        
        if ! mountpoint -q "$MOUNT_POINT"; then
          echo "Warning: $MOUNT_POINT is not mounted, skipping setup"
          exit 0
        fi
        
        echo "Setting up gaming storage structure in $MOUNT_POINT"
        
        # Create standard gaming directories if they don't exist
        mkdir -p "$MOUNT_POINT/SteamLibrary"
        mkdir -p "$MOUNT_POINT/SteamLibrary/steamapps"
        mkdir -p "$MOUNT_POINT/SteamLibrary/steamapps/common"
        mkdir -p "$MOUNT_POINT/SteamLibrary/steamapps/downloading"
        mkdir -p "$MOUNT_POINT/SteamLibrary/steamapps/shadercache"
        mkdir -p "$MOUNT_POINT/Lutris"
        mkdir -p "$MOUNT_POINT/Heroic"
        mkdir -p "$MOUNT_POINT/WinePrefix"
        mkdir -p "$MOUNT_POINT/ROMs"
        mkdir -p "$MOUNT_POINT/Mods"
        mkdir -p "$MOUNT_POINT/Saves"
        
        # Set ownership and permissions for game user
        if id "$GAME_USER" >/dev/null 2>&1; then
          echo "Setting permissions for game user: $GAME_USER"
          
          # Set ownership to game user for new directories
          chown -R "$GAME_USER:games" "$MOUNT_POINT/SteamLibrary" 2>/dev/null || true
          chown -R "$GAME_USER:games" "$MOUNT_POINT/Lutris" 2>/dev/null || true
          chown -R "$GAME_USER:games" "$MOUNT_POINT/Heroic" 2>/dev/null || true
          chown -R "$GAME_USER:games" "$MOUNT_POINT/WinePrefix" 2>/dev/null || true
          chown -R "$GAME_USER:games" "$MOUNT_POINT/ROMs" 2>/dev/null || true
          chown -R "$GAME_USER:games" "$MOUNT_POINT/Mods" 2>/dev/null || true
          chown -R "$GAME_USER:games" "$MOUNT_POINT/Saves" 2>/dev/null || true
          
          # Ensure existing games remain accessible (don't change ownership of existing data)
          # Just set permissions to allow access
          find "$MOUNT_POINT" -type d -exec chmod g+rx {} \; 2>/dev/null || true
          find "$MOUNT_POINT" -type f -exec chmod g+r {} \; 2>/dev/null || true
          
          # Create symlinks in game user's home directory
          GAME_HOME="/home/$GAME_USER"
          if [ -d "$GAME_HOME" ]; then
            echo "Creating convenience symlinks in $GAME_HOME"
            
            # Steam library symlink
            ln -sf "$MOUNT_POINT/SteamLibrary" "$GAME_HOME/SteamLibrary" 2>/dev/null || true
            
            # Gaming directories symlinks
            mkdir -p "$GAME_HOME/Games"
            ln -sf "$MOUNT_POINT/Lutris" "$GAME_HOME/Games/Lutris" 2>/dev/null || true
            ln -sf "$MOUNT_POINT/Heroic" "$GAME_HOME/Games/Heroic" 2>/dev/null || true
            ln -sf "$MOUNT_POINT/ROMs" "$GAME_HOME/Games/ROMs" 2>/dev/null || true
            ln -sf "$MOUNT_POINT/Mods" "$GAME_HOME/Games/Mods" 2>/dev/null || true
            ln -sf "$MOUNT_POINT/Saves" "$GAME_HOME/Games/Saves" 2>/dev/null || true
            
            # Wine prefix symlink
            ln -sf "$MOUNT_POINT/WinePrefix" "$GAME_HOME/.wine" 2>/dev/null || true
            
            # Set ownership of symlinks
            chown -h "$GAME_USER:$GAME_USER" "$GAME_HOME/SteamLibrary" 2>/dev/null || true
            chown -h "$GAME_USER:$GAME_USER" "$GAME_HOME/Games"/* 2>/dev/null || true
            chown -h "$GAME_USER:$GAME_USER" "$GAME_HOME/.wine" 2>/dev/null || true
          fi
        else
          echo "Game user $GAME_USER not found, skipping user-specific setup"
        fi
        
        echo "Gaming storage setup completed"
      '';
    };

    # Udev rules for gaming storage optimization
    services.udev.extraRules = ''
      # Optimize scheduler for gaming storage device
      ACTION=="add|change", KERNEL=="sda", ATTR{queue/scheduler}="mq-deadline"
      ACTION=="add|change", KERNEL=="sda", ATTR{queue/read_ahead_kb}="256"
      ACTION=="add|change", KERNEL=="sda", ATTR{queue/nr_requests}="128"
      
      # Disable power management for gaming storage
      ACTION=="add", SUBSYSTEM=="block", KERNEL=="sda", ATTR{../power/control}="on"
      
      # Set nice I/O scheduling for gaming processes accessing the storage
      ACTION=="add", SUBSYSTEM=="block", KERNEL=="sda", TAG+="systemd", ENV{SYSTEMD_WANTS}+="gaming-storage-optimization.service"
    '';

    # Gaming storage optimization service
    systemd.services.gaming-storage-optimization = {
      description = "Optimize gaming storage performance";
      after = [ "${lib.strings.replaceStrings ["/"] ["-"] config.gaming.storage.mountPoint}.mount" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      
      script = ''
        DEVICE="${config.gaming.storage.device}"
        
        if [ -b "$DEVICE" ]; then
          echo "Optimizing gaming storage: $DEVICE"
          
          # Set I/O scheduler
          echo mq-deadline > /sys/block/$(basename $DEVICE)/queue/scheduler 2>/dev/null || true
          
          # Set read-ahead
          echo 256 > /sys/block/$(basename $DEVICE)/queue/read_ahead_kb 2>/dev/null || true
          
          # Set request queue size
          echo 128 > /sys/block/$(basename $DEVICE)/queue/nr_requests 2>/dev/null || true
          
          # Disable NCQ if it's causing issues (uncomment if needed)
          # echo 1 > /sys/block/$(basename $DEVICE)/queue/nomerges 2>/dev/null || true
          
          echo "Gaming storage optimization completed"
        else
          echo "Gaming storage device $DEVICE not found"
        fi
      '';
    };

    # Create games group
    users.groups.games = {
      gid = 996;  # Fixed GID for games group
    };

    # System packages for storage management
    environment.systemPackages = with pkgs; [
      # File system utilities
      ntfs3g
      exfat
      dosfstools
      e2fsprogs
      btrfs-progs
      xfsprogs
      
      # Storage monitoring
      smartmontools
      hdparm
      iotop
      
      # File management
      rsync
      rclone
      
      # Backup utilities
      borgbackup
    ];

    # Gaming storage management scripts
    environment.etc = {
      "gaming-storage/mount-games.sh" = {
        mode = "0755";
        text = ''
          #!/bin/bash
          # Manual gaming storage mount script
          
          DEVICE="${config.gaming.storage.device}"
          MOUNT_POINT="${config.gaming.storage.mountPoint}"
          
          if [ "$1" = "mount" ]; then
            echo "Mounting gaming storage..."
            mkdir -p "$MOUNT_POINT"
            if mount "$DEVICE" "$MOUNT_POINT"; then
              echo "Gaming storage mounted at $MOUNT_POINT"
              systemctl start setup-gaming-storage.service
            else
              echo "Failed to mount gaming storage"
              exit 1
            fi
            
          elif [ "$1" = "unmount" ]; then
            echo "Unmounting gaming storage..."
            if umount "$MOUNT_POINT"; then
              echo "Gaming storage unmounted"
            else
              echo "Failed to unmount gaming storage (may be in use)"
              lsof +D "$MOUNT_POINT" 2>/dev/null || true
              exit 1
            fi
            
          elif [ "$1" = "status" ]; then
            echo "Gaming storage status:"
            if mountpoint -q "$MOUNT_POINT"; then
              echo "  Status: Mounted"
              echo "  Device: $DEVICE"
              echo "  Mount point: $MOUNT_POINT"
              df -h "$MOUNT_POINT" | tail -1
              echo
              echo "Game directories:"
              ls -la "$MOUNT_POINT" 2>/dev/null | grep -E '^d' || echo "  No directories found"
            else
              echo "  Status: Not mounted"
              echo "  Device: $DEVICE"
              if [ -b "$DEVICE" ]; then
                echo "  Device exists but not mounted"
              else
                echo "  Device not found"
              fi
            fi
            
          else
            echo "Usage: $0 [mount|unmount|status]"
            echo "  mount   - Mount gaming storage"
            echo "  unmount - Unmount gaming storage"
            echo "  status  - Show gaming storage status"
          fi
        '';
      };

      "gaming-storage/backup-saves.sh" = {
        mode = "0755";
        text = ''
          #!/bin/bash
          # Backup game saves from gaming storage
          
          MOUNT_POINT="${config.gaming.storage.mountPoint}"
          BACKUP_DIR="/home/${config.gaming.storage.gameUser}/Documents/GameBackups"
          DATE=$(date +%Y%m%d-%H%M%S)
          
          if ! mountpoint -q "$MOUNT_POINT"; then
            echo "Gaming storage not mounted"
            exit 1
          fi
          
          echo "Creating game saves backup..."
          mkdir -p "$BACKUP_DIR"
          
          # Backup Steam saves
          if [ -d "$MOUNT_POINT/SteamLibrary/steamapps" ]; then
            echo "Backing up Steam data..."
            tar -czf "$BACKUP_DIR/steam-saves-$DATE.tar.gz" \
              -C "$MOUNT_POINT/SteamLibrary/steamapps" \
              userdata/ 2>/dev/null || echo "No Steam userdata found"
          fi
          
          # Backup custom saves directory
          if [ -d "$MOUNT_POINT/Saves" ]; then
            echo "Backing up custom saves..."
            tar -czf "$BACKUP_DIR/custom-saves-$DATE.tar.gz" \
              -C "$MOUNT_POINT" \
              Saves/ 2>/dev/null || echo "No custom saves found"
          fi
          
          echo "Backup completed: $BACKUP_DIR"
          ls -la "$BACKUP_DIR"
        '';
      };
    };
  };
}