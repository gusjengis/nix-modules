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
    };

    services.gnome.gnome-keyring.enable = true;

    security.pam.services = {
      login.enableGnomeKeyring = true;
      gdm.enableGnomeKeyring = true; # or sddm, etc.
    };

    environment.systemPackages = with pkgs; [
      kitty
      wayland
      vulkan-loader
      egl-wayland
      libgbm
      libglvnd
      wayland-protocols
      libxkbcommon
      libGL
      skia
    ];

    xdg.portal.enable = true;
    environment.sessionVariables.XDG_RUNTIME_DIR = "/run/user/$UID";
    services.flatpak.enable = true;

    fonts.packages = with pkgs; [
      cozette
      carlito
      commit-mono
      nerd-fonts.meslo-lg
      fragment-mono
      helvetica-neue-lt-std
    ];
  };
}
