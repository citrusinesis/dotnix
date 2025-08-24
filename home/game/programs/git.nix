{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Game User";
    userEmail = "game@localhost";

    ignores = [
      ".DS_Store"
      "*.swp"
      ".direnv"
      "result"
      ".vscode"
      ".idea"
      "*.log"
      "*.bak"
      "tmp"
      # Gaming-specific ignores
      "*.save"
      "*.cache"
      "steam_*"
    ];

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "vim";
      color.ui = "auto";
    };

    aliases = {
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
      last = "log -1 HEAD";
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };
  };
}