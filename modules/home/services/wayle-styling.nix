{ config, ... }: {
  # Manually maps Stylix base16 colors to Wayle's palette.
  # Remove this file and its import once a Stylix target for Wayle exists.
  services.wayle.settings = {
    general = {
      font-sans = config.stylix.fonts.sansSerif.name;
      font-mono = config.stylix.fonts.monospace.name;
    };
    styling = {
      theme-provider = "wayle";
      palette = {
        bg       = "#${config.lib.stylix.colors.base01}";
        surface  = "#${config.lib.stylix.colors.base00}";
        elevated = "#${config.lib.stylix.colors.base02}";
        fg-muted = "#${config.lib.stylix.colors.base04}";
        fg       = "#${config.lib.stylix.colors.base05}";
        red      = "#${config.lib.stylix.colors.base08}";
        yellow   = "#f9f06b";
        green    = "#${config.lib.stylix.colors.base0B}";
        blue     = "#${config.lib.stylix.colors.base0C}";
      };
    };
  };
}
