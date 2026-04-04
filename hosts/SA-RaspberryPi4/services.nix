{ config, ... }: {
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
        "registry.sethechosenone.dev" = {
          useACMEHost = "sethechosenone.dev";
          forceSSL = true;
          locations."/".proxyPass = "http://localhost:5000";
        };
        "vault.sethechosenone.dev".useACMEHost = "sethechosenone.dev";
      };
    };
    vaultwarden = {
      enable = true;
      domain = "vault.sethechosenone.dev";
      configureNginx = true;
      environmentFile = config.sops.secrets.vaultwarden.path;
      config = {
        ROCKET_PORT = 8222;
        SIGNUPS_ALLOWED = true;
      };
    };
  };
}
