{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sunshine;
  ensureCredentials = pkgs.writeShellScript "sunshine-ensure-credentials" ''
    set -eu

    home_dir="''${HOME:-/home/gusjengis}"
    if [ -n "''${SUNSHINE_PAIRING_ENV:-}" ]; then
      secrets_files="''${SUNSHINE_PAIRING_ENV}"
    else
      secrets_files="$home_dir/.config/secrets/api_keys/env_vars $home_dir/.config/secrets/sunshine/env"
    fi

    for secrets_file in $secrets_files; do
      if [ -r "$secrets_file" ]; then
        set -a
        . "$secrets_file"
        set +a
      fi
    done

    username="''${SUNSHINE_USERNAME:-''${SUNSHINE_USER:-}}"
    password="''${SUNSHINE_PASSWORD:-}"
    if [ -z "$username" ] || [ -z "$password" ]; then
      exit 0
    fi

    exec ${lib.getExe config.services.sunshine.package} --creds "$username" "$password"
  '';
in
{
  options.sunshine.enable = lib.mkEnableOption "Sunshine host support for Moonlight streaming";

  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      autoStart = false;
      capSysAdmin = true;
      openFirewall = true;

      settings = {
        output_name = "sunshine-stream";
        sunshine_name = config.networking.hostName;
      };

      applications = {
        env.PATH = "$(PATH):$(HOME)/.local/bin";
        apps = [
          {
            name = "Desktop";
            image-path = "desktop.png";
          }
        ];
      };
    };

    systemd.user.services.sunshine.serviceConfig.ExecStartPre = ensureCredentials;
  };
}
