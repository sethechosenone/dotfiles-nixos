{ pkgs, ... }:
let
  ollamaUnload = pkgs.writeShellScript "ollama-unload-all" ''
    host="http://172.30.0.1:11434"
    ${pkgs.curl}/bin/curl -fsS --max-time 2 "$host/api/ps" \
      | ${pkgs.jq}/bin/jq -r '.models[].model' \
      | while read -r model; do
          ${pkgs.curl}/bin/curl -fsS --max-time 5 "$host/api/generate" \
            -d "{\"model\":\"$model\",\"keep_alive\":0}" > /dev/null
        done
  '';
in {
  programs = {
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [ looking-glass-obs ];
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
    };
    gamemode = {
      enable = true;
      settings = {
        general.renice = 10;
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
        };
        custom.start = "${ollamaUnload}";
      };
    };
  };
}
