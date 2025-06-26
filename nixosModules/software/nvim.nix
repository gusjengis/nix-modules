{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    nvim.enable = lib.mkEnableOption "enables nvim";
  };

  config = lib.mkIf config.nvim.enable {

    environment.systemPackages = with pkgs; [
      neovim
      nixfmt-rfc-style
      wl-clipboard
      ripgrep
      fzf
      gcc
      gnumake
      rustup
      cargo
    ];

  };
}
