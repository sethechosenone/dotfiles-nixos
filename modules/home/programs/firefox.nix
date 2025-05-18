{ pkgs, inputs, ... }:
let
  betterfox = pkgs.fetchFromGitHub {
    owner = "yokoffing";
    repo = "Betterfox";
    rev = "09dd87a3abcb15a88798941e5ed74e4aa593108c";
    hash = "sha256-Uu/a5t74GGvMIJP5tptqbiFiA+x2hw98irPdl8ynGoE=";
  };
in {
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      isDefault = true;
      name = "default";
      extensions.packages =
        with inputs.firefox-addons.packages.${pkgs.system}; [
          bitwarden
          foxyproxy-standard
          tree-style-tab
          ublock-origin
        ];
      settings = {
        "extensions.allowPrivateBrowsingByDefault" = true;
        # TELEMETRY
        "browser.ping-centre.telemetry" = false;
        "devtools.onboarding.telemetry.logged" = false;
        "extensions.webcompat-reporter.enabled" = false;
        "browser.urlbar.eventTelemetry.enabled" = false;
        # PERFS
        "media.rdd-ffmpeg.enabled" = true;
        "widget.dmabuf.force-enabled" = true;
        "media.ffvpx.enabled" = false;
        "media.rdd-vpx.enabled" = false;
        # TWEAKS
        "browser.cache.memory.capacity" = -1;
        "middlemouse.paste" = false;
        "network.dns.echconfig.enabled" = true;
        "browser.tabs.loadBookmarksInTabs" = true;
        "browser.urlbar.maxRichResults" = true;
        # PRIVACY
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "app.normandy.enabled" = false;
      };
      bookmarks = {
        force = true;
        settings = [
          {
            name = "Nix";
            toolbar = false;
            bookmarks = [
              {
                name = "Nix Package";
                keyword = "np";
                url = "https://search.nixos.org/packages?channel=unstable";
              }
              {
                name = "Nix Options";
                keyword = "no";
                url = "https://search.nixos.org/options?channel=unstable";
              }
            ];
          }
          {
            name = "ProtonMail";
            keyword = "ma";
            url = "https://mail.proton.me/";
          }
          {
            name = "GitHub";
            keyword = "gh";
            url = "https://github.com";
          }
        ];
      };
      extraConfig = ''
        ${builtins.readFile "${betterfox}/user.js"}
        ${builtins.readFile "${betterfox}/Fastfox.js"}
        ${builtins.readFile "${betterfox}/Peskyfox.js"}
        ${builtins.readFile "${betterfox}/Smoothfox.js"}
      '';
      userChrome = "#TabsToolbar { visibility: collapse; }";
    };
  };
  stylix.targets.firefox.profileNames = [ "default" ];
}
