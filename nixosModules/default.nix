{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware/gpu_drivers.nix
    ./hardware/grub.nix
    ./desktop_env/hyprland.nix
    ./desktop_env/gnome.nix
    ./desktop_env/login.nix
    ./software/steam.nix
    ./software/nvim.nix
    ./software/git.nix
  ];

  grub.enable = lib.mkDefault true;
  nvidia.enable = lib.mkDefault true;
  login.gnome.enable = lib.mkDefault true;
  gnome.enable = lib.mkDefault true;
  hyprland.enable = lib.mkDefault true;
  nvim.enable = lib.mkDefault true;
  git.enable = lib.mkDefault true;
  steam.enable = lib.mkDefault true;
}
