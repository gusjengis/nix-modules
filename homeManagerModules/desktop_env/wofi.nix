{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    wofi.enable = lib.mkEnableOption "enables wofi";
  };

  config = lib.mkIf config.wofi.enable {

    home.packages = with pkgs; [ wofi ];

    home.activation.symlinkWofiConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      default_conf_dir="/etc/nix-modules/homeManagerModules/config_files/wofi/"
      home_manager_conf_dir="$HOME/.home-manager/config_files/wofi"
      target_conf_dir="~/.config/wofi"

      # Check if target dir exists and has files
      if [ ! -d "$home_manager_conf_dir" ] || [ -z "$(ls -A "$home_manager_conf_dir" 2>/dev/null)" ]; then
        echo "Copying default wofi config..."
        mkdir -p "$home_manager_conf_dir"
        cp -rn "$default_conf_dir/"* "$home_manager_conf_dir/"
      fi

      # Ensure the config dir exists
      mkdir -p "$target_conf_dir"

      ln -sf $home_manager_conf_dir/config $target_conf_dir/config
      ln -sf $home_manager_conf_dir/style.css $target_conf_dir/style.css
    '';
  };
}
