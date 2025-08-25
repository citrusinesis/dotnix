{ ... }: {
  programs.kitty = {
    enable = true;

    settings = {
      font_family = "Hack Nerd Font Mono";
      bold_font = "auto";
      italic_font = "auto";
      font_size = 12.0;

      background = "#1E1E2E"; # Catppuccin Macchiato background
      foreground = "#CDD6F4"; # Catppuccin Macchiato foreground
      cursor = "#F5E0DC";     # Catppuccin Macchiato Rosewater

      # Cursor settings
      cursor_shape = "block";
      cursor_beam_thickness = "1.5";
      cursor_blink_interval = "0"; # No blinking cursor

      # Scrollback settings
      scrollback_lines = 10000;
      scrollback_pager_history_size = 100;

      # Tab bar
      tab_bar_style = "powerline";
      tab_bar_background = "#181825";

      # Window layout and padding
      window_padding_width = "4";

      # Bell settings
      enable_audio_bell = "no";
      visual_bell_duration = "0.1";

      # Performance settings
      repaint_delay = 10; 
      input_delay = 3;  

      # Keybindings
      "map ctrl+shift+enter" = "new_window";
      "map ctrl+shift+t" = "new_tab";
      "map ctrl+shift+up" = "scroll_line_up";
      "map ctrl+shift+down" = "scroll_line_down";
      "map ctrl+shift+right" = "next_window";
      "map ctrl+shift+left" = "previous_window";
    };
  };
}