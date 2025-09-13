{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza --icons -hl";
      view = "bat";
      edit = "nvim";
      edit-user-config = "nvim ~/.config/nixos/home.nix";
      edit-system-config = "sudo -e /etc/nixos/configuration.nix";
      rebuild = "sudo nixos-rebuild switch";
    };
    autosuggestions = {
      enable = true;
      strategy = [ "history" "completion" ];
    };
    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = if builtins.getEnv "TERM" == "linux" then "cypher" else "agnoster";
    };
  };
}
