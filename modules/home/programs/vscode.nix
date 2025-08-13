{ pkgs, inputs, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    mutableExtensionsDir = false;
    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        arrterian.nix-env-selector
        mkhl.direnv
        visualstudioexptteam.vscodeintellicode
        visualstudioexptteam.intellicode-api-usage-examples
        gruntfuggly.todo-tree
        ms-python.python
        ms-python.vscode-pylance
        ms-python.debugpy
        rust-lang.rust-analyzer
        vscodevim.vim
        leonardssh.vscord
      ];
      userSettings = {
        "window.controlsStyle" = "hidden";
        "vim.smartRelativeLine" = true;
        "git.autofetch" = true;
        "vscord.app.name" = "VSCodium";
      };
    };
  };
}