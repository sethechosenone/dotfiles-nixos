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
    configPath = ".mozilla/firefox";
    profiles.default = {
      id = 0;
      isDefault = true;
      name = "default";
      extensions = {
        force = true;
        packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          bitwarden
          ublock-origin
          simplelogin
          user-agent-string-switcher
        ];
      };
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
        # SIDEBAR
        "sidebar.verticalTabs" = true;
        "sidebar.revamp.round-content-area" = true;
        # PRIVACY
        "privacy.resistFingerprinting" = true;
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "app.normandy.enabled" = false;
        "network.dns.blockDotOnion" = false;
        "dom.security.https_only_mode.upgrade_onion" = true;
      };
      bookmarks = {
        force = true;
        settings = [
          {
            name = "Nix";
            toolbar = true;
            bookmarks = [
              {
                name = "Nix Packages";
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
            name = "Personal";
            toolbar = true;
            bookmarks = [
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
          }
        ];
      };
      extraConfig = ''
        ${builtins.readFile "${betterfox}/user.js"}
        ${builtins.readFile "${betterfox}/Fastfox.js"}
        ${builtins.readFile "${betterfox}/Peskyfox.js"}
        ${builtins.readFile "${betterfox}/Smoothfox.js"}
      '';
      userChrome = ''
        #TabsToolbar { visibility: collapse; }
        .titlebar-close { display: none !important; }
      '';
    };
  };
  stylix.targets.firefox = {
    colorTheme.enable = true;
    profileNames = [ "default" ];
  };
}
