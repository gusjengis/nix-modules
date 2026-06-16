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
    rev = "c018b06d39b8bee63178e976ea7bdc608c36a60e";
    hash = "sha256-TTZzeFPMprVIvQlSpaYDhgvuW6hPVy5KES179raI20A=";
  };

  initialSettings = pkgs.writeText "joshs-mass-settings.json" (
    builtins.toJSON {
      core = {
        webserver = {
          domain = "webserver";
          values = {
            bind_port = 8096;
            base_url = "http://${config.networking.hostName}.local:8096";
          };
        };
        streams = {
          domain = "streams";
          values = {
            bind_port = 8098;
          };
        };
      };
    }
  );
in
{
  options = {
    joshsMass.enable = lib.mkEnableOption "enables Josh's Music Assistant";
  };

  config = lib.mkIf config.joshsMass.enable {
    virtualisation.docker.enable = true;

    systemd.services.joshs-mass = {
      description = "Josh's Music Assistant";
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
        ExecStartPre = [
          "-${lib.getExe pkgs.docker} rm -f joshs-mass"
          "${lib.getExe pkgs.docker} run --rm --pull=missing --entrypoint /bin/sh -v joshs-mass:/data -v ${initialSettings}:/settings.json:ro ghcr.io/music-assistant/server:latest -c 'test -f /data/settings.json || cp /settings.json /data/settings.json'"
        ];
        ExecStart = "${lib.getExe pkgs.docker} run --name=joshs-mass --rm --pull=missing --network=host --privileged -v joshs-mass:/data -v ${ytmusicFreeProvider}/ytmusic_free:/app/venv/lib/python3.14/site-packages/music_assistant/providers/ytmusic_free:ro -e TZ=America/Los_Angeles ghcr.io/music-assistant/server:latest";
        ExecStop = "${lib.getExe pkgs.docker} stop joshs-mass";
        ExecStopPost = "-${lib.getExe pkgs.docker} rm -f joshs-mass";
      };
    };

    networking.firewall.allowedTCPPorts = [
      8096 # web UI
      8098 # stream server
    ];

    networking.firewall.allowedUDPPorts = [
      5353 # mDNS / Zeroconf
      1900 # SSDP / UPnP
    ];
  };
}
