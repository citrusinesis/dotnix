{ lib, config, pkgs, ... }:

{
  programs.starship = {
    enable = true;

    # Enable in bash and zsh
    enableBashIntegration = true;
    enableZshIntegration = true;

    # Custom settings
    settings = {
      # General settings
      add_newline = true;
      scan_timeout = 10;
      command_timeout = 1000;

      # Individual components
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vicmd_symbol = "[❮](bold green)";
      };
    };
  };

  # Ensure XDG config directory exists
  home.activation.starshipConfigDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ${config.xdg.configHome}
  '';
}
