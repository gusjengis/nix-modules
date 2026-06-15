{
  config,
  lib,
  ...
}:

{
  options = {
    musicAssistant.enable = lib.mkEnableOption "enables Music Assistant";
  };

  config = lib.mkIf config.musicAssistant.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers = {
      backend = lib.mkForce "docker";
      containers.musicassistant = {
        volumes = [ "music-assistant:/data" ];
        environment.TZ = "America/Los_Angeles";
        image = "ghcr.io/music-assistant/server:latest"; # Warning: if the tag does not change, the image will not be updated
        extraOptions = [
          "--network=host"
          "--privileged"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [
      8095 # web UI
    ];

    networking.firewall.allowedUDPPorts = [
      5353 # mDNS / Zeroconf
      1900 # SSDP / UPnP
    ];
  };
}
