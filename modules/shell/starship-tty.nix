{ pkgs, ... }:

let
  ttySettings = {
    add_newline = false;
    format = "$username[@](fg:black bg:bright-blue)$hostname[](fg:bright-blue bg:white)$directory$nix_shell$status[ ](fg:white)";
    username = {
      show_always = true;
      style_user = "fg:black bg:bright-blue";
      style_root = "fg:bright-red bg:bright-blue";
      format = "[ $user]($style)";
    };
    hostname = {
      ssh_only = false;
      style = "fg:black bg:bright-blue";
      format = "[$hostname ]($style)";
    };
    directory = {
      read_only = "! readonly !";
      read_only_style = "fg:bright-red bg:white";
      truncation_length = 4;
      truncation_symbol = ".../";
      style = "fg:black bg:white";
      format = "[ $path ]($style)[$read_only ]($read_only_style)";
    };
    nix_shell = {
      symbol = "";
      pure_msg = "pure";
      impure_msg = "! impure !";
      style = "bg:white fg:black";
      format = "[-> $name ]($style)[$state ](fg:bright-red bg:white)";
    };
    status = {
      disabled = false;
      symbol = "";
      style = "fg:bright-red bg:white";
      format = "[exit: $status ]($style)";
    };
  };

  tomlFormat = pkgs.formats.toml {};
  ttyConfigFile = tomlFormat.generate "starship-tty.toml" ttySettings;
in
{
  xdg.configFile."starship-tty.toml".source = ttyConfigFile;
}
