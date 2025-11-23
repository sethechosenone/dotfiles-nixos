{
  programs.kitty = {
    enable = true;
    keybindings = {
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";
    };
    shellIntegration = {
      mode = "no-cursor";
      enableZshIntegration = true;
    };
    settings = {
      cursor_shape = "underline";
      cursor_blink_interval = "0.2";
      cursor_stop_blinking_after = 0;
      confirm_os_window_close = 2;
    };
  };
}
