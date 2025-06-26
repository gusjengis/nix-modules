{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  options = {
    hyprland.enable = lib.mkEnableOption "enables hyprland";
  };

  config = lib.mkIf config.hyprland.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    };

    services.gnome.gnome-keyring.enable = true;

    security.pam.services = {
      login.enableGnomeKeyring = true;
      gdm.enableGnomeKeyring = true; # or sddm, etc.
    };

    environment.systemPackages = with pkgs; [
      kitty
    ];

  };
}
