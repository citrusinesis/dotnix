{ config, lib, pkgs, inputs, username, ... }:
{
  # Import modular program configurations
  imports = [
    ./programs
  ];


  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = lib.mkDefault (
    if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}"
  );

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Configure packages
  home.packages = with pkgs; [
    # Editors and terminal utilities
    neovim
    tmux

    # Nix
    nil
    nixd
    nixfmt-rfc-style

    # Development tools
    ripgrep
    fd
    jq
    tree

    # Command line utilities
    btop
    bat
    eza
    fzf

    # Version control
    gh

    # Additional utilities
    file
    du-dust
    duf
    procs

    # Platform-specific packages
    (lib.mkIf pkgs.stdenv.isDarwin coreutils)
    
    # Example: Use packages from different channels via overlay
    # System unstable: pkgs.unstable.some-package
    # Bleeding edge (fastest): pkgs.bleeding.some-package
    pkgs.bleeding.claude-code
    pkgs.bleeding.firefox
  ];

  # Additional home configurations based on platform
  # Use lib.mkIf to conditionally apply settings based on the platform
  # Example:
  # programs.some-macos-specific-tool.enable = lib.mkIf pkgs.stdenv.isDarwin true;
  # programs.some-linux-specific-tool.enable = lib.mkIf pkgs.stdenv.isLinux true;
}
