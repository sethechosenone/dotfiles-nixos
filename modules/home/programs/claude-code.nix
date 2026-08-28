{
  programs.claude-code = {
    enable = true;
    settings = {
      model = "sonnet";
      enabledPlugins = {
        "frontend-design@claude-plugins-official" = true;
        "rocky@rocky" = false;
        "rust-analyzer-lsp@claude-plugins-official" = true;
        "clangd-lsp@claude-plugins-official" = true;
      };
      effortLevel = "high";
      tui = "fullscreen";
      showThinkingSummaries = true;
      editorMode = "normal";
      verbose = true;
      switchModelsOnFlag = true;
      permissions.ask = [ "Edit" "Write" "NotebookEdit" ];
    };
  };
}
