{ config, pkgs, lib, ... }:

{
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
  ];

  # Gaming user account
  users.users.game = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "audio" "video" "input" "gamemode" ];
    shell = pkgs.zsh;
    description = "Gaming User";
  };
}