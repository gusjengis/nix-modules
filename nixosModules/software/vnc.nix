{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.vnc;
in
{
  options.vnc.enable = lib.mkEnableOption "VNC server and client support for desktop systems";

  config = lib.mkIf cfg.enable {
    programs.wayvnc.enable = lib.mkDefault config.hyprland.enable;
    services.gnome.gnome-remote-desktop.enable = lib.mkDefault config.gnome.enable;

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 5900 ];

    environment.systemPackages = with pkgs; [
      remmina
      tigervnc
      wayvnc
    ];
  };
}
