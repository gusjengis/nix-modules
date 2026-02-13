{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    waypipe
    wofi
  ];

  # graphics so remote guis work
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # create a oneshot job to authenticate to Tailscale
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [
      "network-pre.target"
      "tailscale.service"
    ];
    wants = [
      "network-pre.target"
      "tailscale.service"
    ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      if [ -f /home/gusjengis/.config/secrets/api_keys/env_vars ]; then
        source /home/gusjengis/.config/secrets/api_keys/env_vars
      fi

      if [ -z "''${TAILSCALE_AUTH_KEY:-}" ]; then
        echo "TAILSCALE_AUTH_KEY missing; skipping tailscale up"
        exit 0
      fi


      ${tailscale}/bin/tailscale up -authkey "$TAILSCALE_AUTH_KEY"
      # --ssh --accept-dns=true
    '';
  };
}
