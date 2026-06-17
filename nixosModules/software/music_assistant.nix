{
  config,
  lib,
  pkgs,
  ...
}:

let
  resolvConf = pkgs.writeText "music-assistant-resolv.conf" "nameserver 1.1.1.1\nnameserver 8.8.8.8\noptions edns0\n";

  ytmusicFreeProvider = pkgs.fetchFromGitHub {
    owner = "gusjengis";
    repo = "music-assistant-ytmusic";
    rev = "d34a40091959e77b4bd07047726de9644b0c3fef";
    hash = "sha256-VMuRXoaQS+EAlpPBGGT4JoJecIAr/pfyfYFyzIktSfU=";
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
        ExecStart = "${lib.getExe pkgs.docker} run --name=musicassistant --rm --pull=missing --network=host --privileged -v music-assistant:/data -v ${resolvConf}:/etc/resolv.conf:ro -v ${ytmusicFreeProvider}/ytmusic_free:/app/venv/lib/python3.14/site-packages/music_assistant/providers/ytmusic_free:ro -e TZ=America/Los_Angeles ghcr.io/music-assistant/server:latest";
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
