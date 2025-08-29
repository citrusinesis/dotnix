{ config, lib, pkgs, ... }:

{
  # Import all program configurations
  imports = [
    ./git.nix
    ./zsh.nix
    ./ssh.nix
    ./direnv.nix
    ./starship.nix
    ./vscode.nix
    ./kitty.nix
    ./neovim.nix
    ./podman.nix
  ];
}
