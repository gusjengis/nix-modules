{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  options = {
    homeAssistant.enable = lib.mkEnableOption "enables hyprland";
  };

  config = lib.mkIf config.homeAssistant.enable {
    virtualisation.oci-containers = {
      backend = "podman";
      containers.homeassistant = {
        volumes = [ "home-assistant:/config" ];
        environment.TZ = "America/Los_Angeles";
        image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
        extraOptions = [
          "--network=host"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [
      8123 # webU
      5580 # matter
    ];

    networking.firewall.allowedUDPPorts = [
      5353 # mDNS / Zeroconf
      1900 # SSDP / UPnP
    ];

    services.matter-server.enable = true;
    nixpkgs.config.permittedInsecurePackages = [
      "openssl-1.1.1w" # supposedly matter needs this
    ];
  };
}
