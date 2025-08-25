{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared
    ../../modules/nixos
    
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = lib.mkForce false;

  # Basic system configuration
  networking.hostName = "blender";
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "Asia/Seoul";

  # Select internationalisation properties
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "ko_KR.UTF-8";
      LC_IDENTIFICATION = "ko_KR.UTF-8";
      LC_MEASUREMENT = "ko_KR.UTF-8";
      LC_MONETARY = "ko_KR.UTF-8";
      LC_NAME = "ko_KR.UTF-8";
      LC_NUMERIC = "ko_KR.UTF-8";
      LC_PAPER = "ko_KR.UTF-8";
      LC_TELEPHONE = "ko_KR.UTF-8";
      LC_TIME = "ko_KR.UTF-8";
    };

    inputMethod = {
      enable = true;
      type = "kime";
      kime.iconColor = "White";
    };
  };

  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable KDE Plasma 6 Desktop Environment
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  # Enable sound with PipeWire (recommended for Plasma 6)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    
    # Fix audio delay/pop when starting playback by disabling node suspension
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/disable-suspension.conf" ''
        monitor.alsa.rules = [
          {
            matches = [
              {
                # Matches all sources
                node.name = "~alsa_input.*"
              },
              {
                # Matches all sinks
                node.name = "~alsa_output.*"
              }
            ]
            actions = {
              update-props = {
                session.suspend-timeout-seconds = 0
              }
            }
          }
        ]
        # bluetooth devices
        monitor.bluez.rules = [
          {
            matches = [
              {
                # Matches all sources
                node.name = "~bluez_input.*"
              },
              {
                # Matches all sinks
                node.name = "~bluez_output.*"
              }
            ]
            actions = {
              update-props = {
                session.suspend-timeout-seconds = 0
              }
            }
          }
        ]
      '')
    ];
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };
  services.blueman.enable = true;

  # Nvidia settings
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;

    powerManagement = {
      enable = true;
      finegrained = true;
    };

    prime = {
      offload.enable = true;
      
      intelBusId = lib.mkDefault "PCI:0:2:0"; 
      nvidiaBusId = lib.mkDefault "PCI:2:0:0";
    };
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Gaming configuration
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  
  programs.gamemode.enable = true;
  
  # Gaming support packages (Steam installed per-user)
  environment.systemPackages = with pkgs; [
    # Gaming utilities (available system-wide for all users who might need them)
    mangohud
    protonup-qt
    
    # Performance monitoring
    nvtopPackages.nvidia
    
    # Bluetooth management
    kdePackages.bluedevil
  ];

  # Home Manager backup configuration
  home-manager.backupFileExtension = "backup";

  # Define user accounts
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; 
    shell = pkgs.zsh;
    # User packages managed by home-manager
  };

  # Gaming user account
  users.users.game = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "audio" "video" "input" "gamemode" ];
    shell = pkgs.zsh;
    description = "Gaming User";
  };



  # System packages are defined in shared module

  # Enable the OpenSSH daemon
  services.openssh.enable = true;

  # Open ports in the firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  services.tailscale = {
    enable = true;
    extraSetFlags = [
      "--advertise-exit-node"
      "--ssh"
    ];
  };
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1; 
    "net.ipv4.conf.all.forwarding" = 1; 
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Tailscale UDP optimization for exit nodes (Linux 6.2+ with Tailscale 1.54+)
  systemd.services.tailscale-udp-optimization = {
    description = "Tailscale UDP optimization for exit nodes";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "tailscale-udp-optimize" ''
        #!/bin/sh
        
        # Get the primary network interface
        NETDEV=$(${pkgs.iproute2}/bin/ip -o route get 8.8.8.8 | cut -f 5 -d " ")
        
        if [ -n "$NETDEV" ]; then
          echo "Optimizing network device: $NETDEV"
          ${pkgs.ethtool}/bin/ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off
          echo "Tailscale UDP optimization applied successfully"
        else
          echo "Failed to detect network device"
          exit 1
        fi
      '';
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "25.05"; # DO NOT CHANGE THIS LIGHTLY
}
