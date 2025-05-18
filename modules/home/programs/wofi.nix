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
      * {
        border: 0;
        transition: none;
      }
      /*#text { color: @base05; }*/
      #window,
      #outer-box {
        border-radius: 15px;
        /*background-color: @base00;*/
      }
      #input {
        border-radius: 15px;
        /*background-color: @base01;*/
        /*color: @base05;*/
        border-width: 0;
        margin: 10px 5px;
      }
      #entry:selected { 
        border-radius: 15px;
        padding: 0.5em;
      }
      #entry:unselected { padding: 0.5em; }
      #entry > image { padding: 2px; }
      expander > list { 
        /*background-color: @base01;*/
        border-radius: 15px;
      }
    '';
  };
}
