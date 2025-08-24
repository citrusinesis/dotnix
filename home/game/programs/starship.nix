{ config, lib, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    
    settings = {
      format = "$username$hostname$directory$git_branch$git_status$character";
      
      username = {
        style_user = "bold green";
        style_root = "bold red";
        format = "[$user]($style)";
        disabled = false;
        show_always = true;
      };
      
      hostname = {
        ssh_only = false;
        format = "@[$hostname](bold blue) ";
        disabled = false;
      };
      
      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      
      git_branch = {
        format = "on [$symbol$branch]($style) ";
        style = "bold purple";
      };
      
      git_status = {
        conflicted = "⚡";
        ahead = "⬆";
        behind = "⬇";
        diverged = "⬇⬆";
        untracked = "?";
        stashed = "$";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };
      
      character = {
        success_symbol = "[🎮](bold green)";
        error_symbol = "[🎮](bold red)";
      };
      
      # Add gaming-specific modules
      custom = {
        gamemode = {
          command = "gamemoded -s | grep -q 'is active' && echo '🚀' || echo ''";
          when = "command -v gamemoded";
          format = "[$output]($style)";
          style = "bold yellow";
          shell = [ "bash" "--noprofile" "--norc" ];
        };
      };
    };
  };
}