{ config, lib, pkgs, ... }:

{
  # Import all gaming-specific program configurations
  imports = [
    ./steam.nix
    ./gamemode.nix
    ./mangohud.nix
  ];
}