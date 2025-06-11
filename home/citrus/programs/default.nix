{ config, lib, pkgs, ... }:

{
  # Import all program configurations
  imports = [
    ./git.nix
    ./zsh.nix
    ./ssh.nix
    ./direnv.nix
    ./starship.nix
    # Add any new program configurations here
  ];
}
