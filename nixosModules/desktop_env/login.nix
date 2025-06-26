{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    login.gnome.enable = lib.mkEnableOption "enables gnome login";
  };

  config = lib.mkIf config.login.gnome.enable {
    services.xserver.displayManager.gdm.enable = true;
  };
}
