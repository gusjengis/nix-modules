{
  config,
  lib,
  inputs,
  pkgs,
  stable,
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
    ./users.nix
  ];

  grub.enable = lib.mkDefault true;
  nvidia.enable = lib.mkDefault true;
  login.gnome.enable = lib.mkDefault false;
  gnome.enable = lib.mkDefault false;
  hyprland.enable = lib.mkDefault true;
  nvim.enable = lib.mkDefault true;
  git.enable = lib.mkDefault true;
  steam.enable = lib.mkDefault true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.getty.autologinUser = "gusjengis";
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  time.timeZone = "America/Los_Angeles";
  fonts.packages = with pkgs; [
    cozette
    carlito
    commit-mono
    nerd-fonts.meslo-lg
    fragment-mono
    helvetica-neue-lt-std
  ];
  networking.networkmanager.enable = true;
  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
      {
        from = 47984;
        to = 47990;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
      {
        from = 47998;
        to = 48010;
      }
    ];
    allowedTCPPorts = [
      48010
    ];
  };
  nixpkgs.config.allowBroken = true;
  # Turn of password for sudo, so annoying
  security.sudo.extraConfig = ''
    %wheel ALL=(ALL) NOPASSWD: ALL
  '';
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  nixpkgs.config.allowUnfree = true;
  systemd.services."NetworkManager-wait-online".enable = false;
  environment.systemPackages = with pkgs; [
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
  programs.nix-ld.enable = true;
  virtualisation.docker.enable = true;
  programs.dconf.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  xdg.portal.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  services.gnome.core-apps.enable = false;
}
