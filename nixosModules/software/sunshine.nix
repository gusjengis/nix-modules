{
  config,
  lib,
  ...
}:

let
  cfg = config.sunshine;
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
        output_name = "1";
        sunshine_name = config.networking.hostName;
      };

      applications = {
        env.PATH = "$(PATH):$(HOME)/.local/bin";
        apps = [
          {
            name = "Desktop";
            output = "1";
            image-path = "desktop.png";
          }
        ];
      };
    };
  };
}
