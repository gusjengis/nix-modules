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
    services.home-assistant = {
      enable = true;
      extraComponents = [
        # Components required to complete the onboarding
        "esphome"
        "met"
        "radio_browser"
      ];
      config = {
        # Includes dependencies for a basic setup
        # https://www.home-assistant.io/integrations/default_config/
        default_config = { };
      };
    };

    networking.firewall.allowedTCPPorts = [ 8123 ];
  };
}
