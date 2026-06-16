{
  config,
  lib,
  pkgs,
  ...
}:

let
  ytmusicFreeProvider = pkgs.fetchFromGitHub {
    owner = "gusjengis";
    repo = "music-assistant-ytmusic";
    rev = "959937045b226383b4908640622b010ef8bcf20e";
    hash = "sha256-au0cGe1FD3JoEUvlD1amJyCY/Ed0M7sh/y2JG2cB/Fk=";
  };
in
{
  options = {
    musicAssistant.enable = lib.mkEnableOption "enables Music Assistant";
  };

  config = lib.mkIf config.musicAssistant.enable {
    virtualisation.docker.enable = true;

    systemd.services.musicassistant = {
      description = "Music Assistant";
      after = [
        "docker.service"
        "network-online.target"
      ]
      ++ lib.optionals config.tailscale.enable [ "tailscaled.service" ];
      wants = [
        "docker.service"
        "network-online.target"
      ]
      ++ lib.optionals config.tailscale.enable [ "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 10;
        ExecStartPre = "-${lib.getExe pkgs.docker} rm -f musicassistant";
        ExecStart = "${lib.getExe pkgs.docker} run --name=musicassistant --rm --pull=missing --network=host --privileged -v music-assistant:/data -v ${ytmusicFreeProvider}/ytmusic_free:/app/venv/lib/python3.14/site-packages/music_assistant/providers/ytmusic_free:ro -e TZ=America/Los_Angeles ghcr.io/music-assistant/server:latest";
        ExecStop = "${lib.getExe pkgs.docker} stop musicassistant";
        ExecStopPost = "-${lib.getExe pkgs.docker} rm -f musicassistant";
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
