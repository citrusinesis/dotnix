{ config, lib, pkgs, username, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion = {
      enable = true;
      strategy = [ "completion" ];
    };
    syntaxHighlighting.enable = true;

    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Listing files
      ls = "ls --color=auto";
      ll = "ls -la";
      la = "ls -lah";
      l = "ls -CF";

      # Git shortcuts
      g = "git";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gs = "git status";
      gl = "git log";

      # System commands
      update = if pkgs.stdenv.isDarwin
               then "sudo darwin-rebuild switch --flake ~/.nix-config#squeezer"
               else "sudo nixos-rebuild switch --flake ~/.nix-config#blender";

      # Utilities
      grep = "grep --color=auto";
      df = "df -h";
      free = "free -m";
      mkdir = "mkdir -pv";
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -v";
      cat = "${pkgs.bat}/bin/bat";

      # Quick edit
      zshrc = "$EDITOR ~/.zshrc";
      nixconf = "cd ~/.nixconfig";
    };

    # History configuration
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      expireDuplicatesFirst = true;
      extended = true;
      share = true;
    };

    # Oh My Zsh configuration
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "npm"
        "yarn"
        "sudo"
        "command-not-found"
        "colored-man-pages"
        "extract"
      ];
      # No theme as we're using starship
      theme = "";
    };

    # Additional configuration
    initContent = lib.mkOrder 550 ''
      # Disable oh-my-zsh themes (let starship handle the prompt)
      export ZSH_THEME=""

      # Initialize starship if it's not already initialized
      if [ -z "$STARSHIP_SHELL" ]; then
        eval "$(${pkgs.starship}/bin/starship init zsh)"
      fi

      # Set PATH
      export PATH=$HOME/.local/bin:$PATH

      # Set default editor
      export EDITOR='vim'
      export VISUAL='vim'

      # Bind keys
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      # FZF integration
      if [ -n "''${commands[fzf-share]}" ]; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      fi

      # Load local zshrc if it exists
      if [ -f ~/.zshrc.local ]; then
        source ~/.zshrc.local
      fi

      # Ensure starship is properly initialized as the last step
      if [ -z "$STARSHIP_SHELL" ]; then
        eval "$(${pkgs.starship}/bin/starship init zsh)"
      fi

      # OS-specific configurations
      if [[ "$(uname)" == "Darwin" ]]; then
        # macOS specific settings
        export CLICOLOR=1
        alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
        alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
      else
        # Linux specific settings
        alias open='xdg-open'
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
      fi
    '';

    # Additional shell plugins not in oh-my-zsh
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
    ];
  };

  # Ensure programs that integrate with zsh are installed
  home.packages = with pkgs; [
    fzf
    zsh-completions
    nix-zsh-completions
  ];
}
