{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared
    ../../modules/nixos
  ];

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
  };

  # Define a user account
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable 'sudo' for the user.
    packages = with pkgs; [
      firefox
      git
      vim
    ];
  };

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    vim
    htop
  ];

  # Enable the OpenSSH daemon
  services.openssh.enable = true;

  # Open ports in the firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "25.05"; # DO NOT CHANGE THIS LIGHTLY
}
