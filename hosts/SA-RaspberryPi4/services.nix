{
  services = {
    dockerRegistry = {
      enable = true;
      openFirewall = true;
      listenAddress = "0.0.0.0";
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
  };
}
