{
  config,
  lib,
  pkgs,
  ...
}:

let
  resolvConf = pkgs.writeText "music-assistant-resolv.conf" "nameserver 1.1.1.1\nnameserver 8.8.8.8\noptions edns0\n";

  musicAssistantFork = pkgs.fetchFromGitHub {
    owner = "gusjengis";
    repo = "mass-server";
    rev = "4a71d241c772fb65b06ef446284675df0b722c2b";
    hash = "sha256-FlWXQpHM59NoyfVlV/5CTaEwHdTtwXUd5W4K8DBx6/U=";
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
        ExecStart = "${lib.getExe pkgs.docker} run --name=musicassistant --rm --pull=always --network=host --privileged -v music-assistant:/data -v ${resolvConf}:/etc/resolv.conf:ro -v ${musicAssistantFork}/music_assistant:/app/venv/lib/python3.14/site-packages/music_assistant:ro -e TZ=America/Los_Angeles ghcr.io/music-assistant/server:latest";
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
