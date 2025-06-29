{
  config,
  pkgs,
  lib,
  home,
  ...
}:

{
  options = {
    hyprpaper.enable = lib.mkEnableOption "enables hyprpaper";
  };

  config = lib.mkIf config.hyprpaper.enable {

    home.packages = with pkgs; [ hyprpaper ];

    home.activation.symlinkHyprpaperConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      default_conf_dir="/etc/nix-modules/homeManagerModules/config_files/hypr/"
      home_manager_conf_dir="$HOME/.home-manager/config_files/hypr"
      target_conf_dir="$HOME/.config/hypr"

      # Check if target file exists
      if [ ! -f "$home_manager_conf_dir/hyprpaper.conf" ]; then
        echo "Copying default waybar config..."
        mkdir -p "$home_manager_conf_dir"
        cp -rn "$default_conf_dir/hyprpaper.conf" "$home_manager_conf_dir/hyprpaper.conf"
      fi

      # Ensure the config dir exists
      mkdir -p "$target_conf_dir"

      ln -sf $home_manager_conf_dir/hyprpaper.conf $target_conf_dir/hyprpaper.conf
    '';

    home.activation.copyDefaultWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      default_conf_dir="/etc/nix-modules/homeManagerModules/config_files/wallpapers/"
      home_manager_conf_dir="$HOME/.home-manager/wallpapers/"

      # Check if target dir exists and has files
      if [ ! -d "$home_manager_conf_dir" ] || [ -z "$(ls -A "$home_manager_conf_dir" 2>/dev/null)" ]; then
        echo "Copying default waybar config..."
        mkdir -p "$home_manager_conf_dir"
        cp -rn "$default_conf_dir/"* "$home_manager_conf_dir/"
      fi
    '';
  };
}
