{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./desktop_env/waybar.nix
    ./desktop_env/wofi.nix
    ./desktop_env/hyprpaper.nix
  ];
}
