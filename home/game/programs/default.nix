{ config, lib, pkgs, ... }:

{
  # Import gaming-specific program configurations
  imports = [
    ./git.nix
    ./zsh.nix
    ./starship.nix
    ./kitty.nix
  ];
}