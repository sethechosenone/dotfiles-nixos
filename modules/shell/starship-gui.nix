{ ... }: {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "[ ](fg:#7AA2F7)[](fg:#7AA2F7)$username[@](fg:#171D23 bg:#7AA2F7)$hostname[](fg:#7AA2F7 bg:#D8E2EC)$directory$nix_shell$direnv[](fg:#D8E2EC bg:#B7C5D3)$git_branch$git_status[](fg:#B7C5D3 bg:#526270)$python$rust$golang$nodejs$status[ ](fg:#526270)";
      username = {
        show_always = true;
        style_user = "fg:#171D23 bg:#7AA2F7";
        style_root = "fg:#171D23 bg:#7AA2F7";
        format = "[ $user]($style)";
      };
      hostname = {
        ssh_only = false;
        style = "fg:#171D23 bg:#7AA2F7";
        format = "[$hostname ]($style)";
      };
      directory = {
        read_only = "";
        read_only_style = "fg:#FF9E64 bg:#D8E2EC";
        truncation_length = 4;
        truncation_symbol = ".../";
        style = "fg:#172D23 bg:#D8E2EC";
        format = "[ $path ]($style)[$read_only ]($read_only_style)";
      };
      nix_shell = {
        symbol = "";
        pure_msg = "";
        impure_msg = "";
        style = "bg:#D8E2EC fg:#171D23";
        format = "[$symbol $name ]($style)[$state ](fg:#FF9E64 bg:#D8E2EC)";
      };
      direnv = {
        symbol = "";
        allowed_msg = "";
        not_allowed_msg = "";
        style = "bg:#D8E2EC fg:#171D23";
        format = "[$symbol ]($style)[$allowed ](fg:#F7768E bg:#D8E2EC)";
      };
      git_branch = {
        style = "fg:#172D23 bg:#B7C5D3";
        format = "[ $symbol $branch ]($style)";
      };
      git_status = {
        style = "fg:#172D23 bg:#B7C5D3";
        format = "[($all_status$ahead_behind )]($style)";
      };
      rust = {
        symbol = "";
        style = "fg:#F6F6F8 bg:#526270";
        format = "[ $symbol ($version) ]($style)";
      };
      golang = {
        symbol = "";
        style = "fg:#F6F6F8 bg:#526270";
        format = "[ $symbol ($version) ]($style)";
      };
      nodejs = {
        symbol = "";
        style = "fg:#F6F6F8 bg:#526270";
        format = "[ $symbol ($version) ]($style)";
      };
      python = {
        symbol = "";
        style = "fg:#F6F6F8 bg:#526270";
        format = "[ $symbol ($version) ]($style)";
      };
      status = {
        disabled = false;
        symbol = "󰅙";
        not_executable_symbol = "";
        sigint_symbol = "󰅜";
        not_found_symbol = "󰡯";
        signal_symbol = "󱐋";
        style = "fg:#F7768E bg:#526270";
        format = "[ $symbol ]($style)";
      };
    };
  };
}
