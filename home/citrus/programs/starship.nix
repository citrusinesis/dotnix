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

      # Format of the prompt
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$nix_shell"
        "$direnv"
        "$jobs"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      # Individual components
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vicmd_symbol = "[❮](bold green)";
      };

      username = {
        style_user = "bold blue";
        style_root = "bold red";
        format = "[$user]($style)@";
        disabled = false;
        show_always = true;
      };

      hostname = {
        ssh_only = false;
        format = "[$hostname](bold yellow) ";
        disabled = false;
      };

      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        home_symbol = "~";
        read_only_style = "red";
        read_only = " 🔒";
        format = "[$path]($style)[$read_only]($read_only_style) ";
      };

      git_branch = {
        symbol = " ";
        format = "[$symbol$branch]($style) ";
        style = "bold purple";
      };

      git_status = {
        format = "([\[$all_status$ahead_behind\]]($style) )";
        style = "bold cyan";
      };

      git_state = {
        format = "\([$state( $progress_current/$progress_total)]($style)\)";
        style = "bright-black";
      };

      cmd_duration = {
        min_time = 2000;
        format = "[$duration]($style) ";
        style = "yellow";
      };

      nix_shell = {
        format = "[$symbol$name]($style) ";
        symbol = "❄️ ";
        style = "bold blue";
        heuristic = true;
        pure_msg = "pure";
        impure_msg = "impure";
      };

      direnv = {
        format = "[$symbol$loaded]($style) ";
        symbol = "📂 ";
        style = "bold green";
        disabled = false;
      };

      jobs = {
        format = "[$symbol$number]($style) ";
        symbol = "✦ ";
        style = "bold blue";
        threshold = 1;
      };

      # Language-specific modules
      golang = {
        format = "[$symbol($version)]($style) ";
        symbol = " ";
        style = "bold cyan";
      };

      rust = {
        format = "[$symbol($version)]($style) ";
        symbol = "🦀 ";
        style = "bold red";
      };

      nodejs = {
        format = "[$symbol($version )]($style) ";
        symbol = "⬢ ";
        style = "bold green";
      };

      python = {
        format = "[$symbol$pyenv_prefix($version)(\($virtualenv\))]($style) ";
        symbol = "🐍 ";
        style = "bold yellow";
        detect_extensions = ["py"];
      };

      package = {
        format = "[$symbol$version]($style) ";
        symbol = "📦 ";
        style = "bold 208";
        display_private = true;
      };

      # Nix-specific modules
      custom = {
        nix_profile = {
          command = "nix profile list | wc -l";
          when = "test -e ~/.nix-profile";
          format = "[$symbol$output]($style) ";
          style = "bold blue";
          symbol = "👤 ";
        };

        flake_inputs = {
          command = "grep -c 'inputs' flake.nix 2>/dev/null || echo 0";
          when = "test -e flake.nix";
          format = "[$symbol$output]($style) ";
          style = "bold green";
          symbol = "🔄 ";
        };
      };
    };
  };

  # Make sure zsh integration is enabled if you're using oh-my-zsh
  programs.zsh.initContent = lib.mkIf config.programs.zsh.enable ''
    # Add Starship shell completions
    mkdir -p ${config.xdg.configHome}/zsh/completions
    ${pkgs.starship}/bin/starship completions zsh > ${config.xdg.configHome}/zsh/completions/_starship

    # Configure Starship with specific behavior for Nix
    export STARSHIP_CONFIG=${config.xdg.configHome}/starship.toml

    # Ensure starship is properly initialized
    eval "$(${pkgs.starship}/bin/starship init zsh)"
  '';

  # Make sure bash integration is enabled
  programs.bash.initExtra = lib.mkIf config.programs.bash.enable ''
    # Configure Starship with specific behavior for Nix
    export STARSHIP_CONFIG=${config.xdg.configHome}/starship.toml

    # Ensure starship is properly initialized
    eval "$(${pkgs.starship}/bin/starship init bash)"
  '';

  # Ensure XDG config directory exists
  home.activation.starshipConfigDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ${config.xdg.configHome}
  '';
}
