{ pkgs, lib, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    mutableExtensionsDir = true;
    profiles.default = {
      # enableUpdateCheck = false;
      # enableExtensionUpdateCheck = false;
      # extensions = with pkgs.vscode-extensions; [
      #   jnoortheen.nix-ide
      #   arrterian.nix-env-selector
      #   mkhl.direnv
      #   visualstudioexptteam.vscodeintellicode
      #   visualstudioexptteam.intellicode-api-usage-examples
      #   gruntfuggly.todo-tree
      #   ms-python.python
      #   ms-python.vscode-pylance
      #   ms-python.debugpy
      #   rust-lang.rust-analyzer
      #   vscodevim.vim
      #   leonardssh.vscord
      #   (anthropic.claude-code.overrideAttrs (oldAttrs: {
      #     src = pkgs.fetchurl {
      #       inherit (oldAttrs.src) url;
      #       name = "anthropic-claude-code.vsix";
      #       hash = "sha256-LXUIp+Rqh0prvFLgmbiSVJYHNY2ECVAfK8GLmDRMcxU=";
      #     };
      #   }))
      #   hashicorp.terraform
      # ];
      userSettings = {
        "window.controlsStyle" = "hidden";
        "vim.smartRelativeLine" = true;
        "git.autofetch" = true;
        "vscord.app.name" = "VSCodium";
        "markdown-pdf.executablePath" = "${lib.getExe pkgs.chromium}";
        "claudeCode.claudeProcessWrapper" = "${lib.getExe pkgs.claude-code}";
        "java.jdt.ls.java.home" = "${pkgs.jdk21}/lib/openjdk";
      };
    };
  };
}
