{ config, pkgs, ... }: {
  services = {
    dockerRegistry = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 5000;
      storagePath = "/var/lib/docker-registry";
    };
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    nginx = {
      enable = true;
      virtualHosts = {
        "registry.sethechosenone.dev".locations."/".proxyPass = "http://localhost:5000";
        "vault.sethechosenone.dev".locations."/".proxyPass = "http://localhost:8222";
        "sethadkins.dev" = {
          root = "/var/www/portfolio";
          locations."~* \\.js$". extraConfig = ''
            types { application/javascript js; }
            default_type application/javascript;
          '';
        };
        "sethechosenone.dev" = {
          root = "/var/www/portfolio";
          locations."~* \\.js$". extraConfig = ''
            types { application/javascript js; }
            default_type application/javascript;
          '';
        };
      };
    };
    vaultwarden = {
      enable = true;
      environmentFile = config.sops.secrets.vaultwarden.path;
      config = {
        ROCKET_PORT = 8222;
        SIGNUPS_ALLOWED = false;
        DOMAIN = "https://vault.sethechosenone.dev";
        ROCKET_ADDRESS = "127.0.0.1";
      };
    };
  };
  # cloudflared module is broken so we have to do this
  systemd.services.cloudflared = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token $TUNNEL_TOKEN";
      EnvironmentFile = config.sops.secrets.cloudflare-token.path;
      Restart = "always";
    };
  };
}
