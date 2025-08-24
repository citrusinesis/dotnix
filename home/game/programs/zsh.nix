{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    
    shellAliases = {
      # System shortcuts
      ll = "ls -la";
      la = "ls -A";
      l = "ls -CF";
      
      # Gaming shortcuts
      steam-launch = "steam";
      steam-big = "steam -bigpicture";
      heroic = "heroic";
      lutris = "lutris";
      
      # Performance monitoring
      gpu = "nvtop";
      temp = "watch -n 1 nvidia-smi";
      gamemode = "gamemoded -s";
      
      # Quick navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      
      # Git shortcuts
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline -10";
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
    };

    initContent = ''
      # Gaming-specific environment setup
      export MANGOHUD=1
      export DXVK_HUD=fps
      export STEAM_FRAME_FORCE_CLOSE=1
      
      # Quick functions for gaming
      launch_with_gamemode() {
        gamemoderun "$@"
      }
      
      steam_proton_log() {
        tail -f ~/.steam/steam/logs/content_log.txt
      }
      
      gpu_usage() {
        watch -n 1 'nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv'
      }
    '';

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "sudo"
        "history"
      ];
    };
  };
}