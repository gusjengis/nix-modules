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
      default_conf_dir="/etc/nix-modules/homeManagerModules/config_files/waybar/"
      home_manager_conf_dir="$HOME/.home-manager/config_files/waybar"
      target_conf_dir="$HOME/.config/waybar"

      # Check if target dir exists and has files
      if [ ! -d "$home_manager_conf_dir" ] || [ -z "$(ls -A "$home_manager_conf_dir" 2>/dev/null)" ]; then
        echo "Copying default waybar config..."
        mkdir -p "$home_manager_conf_dir"
        cp -rn "$default_conf_dir/"* "$home_manager_conf_dir/"
      fi

      # Ensure the config dir exists
      mkdir -p "$target_conf_dir"

      ln -sf $home_manager_conf_dir/config $target_conf_dir/config
      ln -sf $home_manager_conf_dir/config.json $target_conf_dir/config.json
      ln -sf $home_manager_conf_dir/style.css $target_conf_dir/style.css
    '';
  };
}
