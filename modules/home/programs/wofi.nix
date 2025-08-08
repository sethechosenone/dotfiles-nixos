{ pkgs, ... }: {
  programs.wofi = {
    enable = true;
    settings = {
      location = "top";
      allow_markup = true;
      allow_images = true;
      width = 750;
      yoffset = 5;
      key_expand = "Tab";
    };
    style = ''
      #window,
      #outer-box {
        border-radius: 15px;
        transition: none;
      }
      #scroll { border-radius: 15px; }
      #input {
        border-radius: 15px;
        border-width: 0;
        margin: 10px 5px;
      }
      #entry:selected { padding: 0.5em; }
      #entry:unselected { padding: 0.5em; }
      #entry > image { padding: 2px; }
      expander > list { border-radius: 15px; }
    '';
  };
}
