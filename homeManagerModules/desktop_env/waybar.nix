{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    waybar.enable = lib.mkEnableOption "enables waybar";
  };

  config = lib.mkIf config.waybar.enable {

    home.packages = with pkgs; [
      waybar
      font-awesome
    ];

    fonts.fontconfig.enable = true;

    home.activation.symlinkWaybarConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ln -sf $HOME/.home-manager/config_files/waybar/config $HOME/.config/waybar/config
      ln -sf $HOME/.home-manager/config_files/waybar/config.json $HOME/.config/waybar/config.json
      ln -sf $HOME/.home-manager/config_files/waybar/style.css $HOME/.config/waybar/style.css
    '';

  };
}
