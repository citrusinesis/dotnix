{ config, pkgs, lib, ... }:

{
  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable KDE Plasma 6 Desktop Environment
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  # Wayland environment variable
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

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

  # System packages for graphics
  environment.systemPackages = with pkgs; [
    # Performance monitoring
    nvtopPackages.nvidia
    
    # Bluetooth management for KDE
    kdePackages.bluedevil
  ];
}