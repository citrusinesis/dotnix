{ config, pkgs, lib, inputs, username, ... }:

let
  personal = import ../../personal.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    
    ../../modules/shared
    ../../modules/nixos

    ./audio.nix
    ./graphics.nix
    ./gaming.nix
    ./networking.nix
    ./power.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = lib.mkForce false;

  # Set your time zone from personal configuration
  time.timeZone = personal.timezone;

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

  # Home Manager backup configuration
  home-manager.backupFileExtension = "backup";

  # Define user accounts
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; 
    shell = pkgs.zsh;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "25.05"; # DO NOT CHANGE THIS LIGHTLY
}
