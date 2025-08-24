{ config, lib, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    
    font = {
      name = "GeistMono NF";
      size = 12;
    };
    
    settings = {
      # Gaming-themed appearance
      background = "#1a1a1a";
      foreground = "#f8f8f2";
      cursor = "#f8f8f0";
      selection_background = "#44475a";
      selection_foreground = "#ffffff";
      
      # Colors (gaming-friendly dark theme)
      color0 = "#21222c";
      color1 = "#ff5555";
      color2 = "#50fa7b";
      color3 = "#f1fa8c";
      color4 = "#8be9fd";
      color5 = "#bd93f9";
      color6 = "#ff79c6";
      color7 = "#f8f8f2";
      color8 = "#6272a4";
      color9 = "#ff6e6e";
      color10 = "#69ff94";
      color11 = "#ffffa5";
      color12 = "#d6acff";
      color13 = "#ff92df";
      color14 = "#a4ffff";
      color15 = "#ffffff";
      
      # Performance settings
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
      
      # Gaming-friendly settings
      copy_on_select = true;
      strip_trailing_spaces = "smart";
      
      # Window settings
      remember_window_size = true;
      initial_window_width = 1200;
      initial_window_height = 800;
      window_padding_width = 4;
      
      # Tab settings
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      active_tab_background = "#bd93f9";
      active_tab_foreground = "#282a36";
      inactive_tab_background = "#44475a";
      inactive_tab_foreground = "#f8f8f2";
    };

    keybindings = {
      # Gaming-friendly shortcuts
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+w" = "close_tab";
      "ctrl+shift+n" = "new_window";
      "ctrl+shift+enter" = "new_window";
      
      # Quick access to gaming tools
      "ctrl+shift+g" = "launch --type=tab --tab-title=GameMode gamemoded -s";
      "ctrl+shift+m" = "launch --type=tab --tab-title=GPU nvtop";
    };
  };
}