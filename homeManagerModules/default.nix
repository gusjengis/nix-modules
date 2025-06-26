{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./desktop_env/waybar.nix
  ];
}
