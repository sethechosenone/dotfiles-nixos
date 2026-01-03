{ ... }: {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$username[@](fg:#171D23 bg:#7AA2F7)$hostname<DIV>(fg:#7AA2F7 bg:#D8E2EC)$directory<DIV>(fg:#D8E2EC bg:#B7C5D3)$nix_shell<DIV>(fg:#B7C5D3 bg:#526270)$status[ ](fg:#526270)";
      username = {
        show_always = true;
        style_user = "fg:#171D23 bg:#7AA2F7";
        style_root = "fg:#F7768E bg:#7AA2F7";
        format = "[ $user]($style)";
      };
      hostname = {
        ssh_only = false;
        style = "fg:#171D23 bg:#7AA2F7";
        format = "[$hostname ]($style)";
      };
      directory = {
        read_only = "! readonly !";
        read_only_style = "fg:#FF9E64 bg:#D8E2EC";
        truncation_length = 4;
        truncation_symbol = ".../";
        style = "fg:#172D23 bg:#D8E2EC";
        format = "[ $path ]($style)[$read_only ]($read_only_style)";
      };
      nix_shell = {
        symbol = "";
        pure_msg = "pure";
        impure_msg = "! impure !";
        style = "bg:#B7C5D3 fg:#171D23";
        format = "[ nix-shell: $name ]($style)[$state ]($style)";
      };
      status = {
        disabled = false;
        symbol = "";
        style = "fg:#F7768E bg:#526270";
        format = "[ exit: $status ]($style)";
      };
    };
  };
}
