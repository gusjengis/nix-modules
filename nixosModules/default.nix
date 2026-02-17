{
  config,
  lib,
  inputs,
  pkgs,
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
    ./software/tailscale.nix
    ./software/vms.nix
    ./software/home_assistant.nix
    ./users.nix
  ];

  grub.enable = lib.mkDefault true;
  nvidia.enable = lib.mkDefault false;
  login.gnome.enable = lib.mkDefault false;
  gnome.enable = lib.mkDefault false;
  hyprland.enable = lib.mkDefault true;
  nvim.enable = lib.mkDefault true;
  git.enable = lib.mkDefault true;
  steam.enable = lib.mkDefault false;
  tailscale.enable = lib.mkDefault true;
  homeAssistant.enable = lib.mkDefault false;
  virtual-machines.enable = lib.mkDefault false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.warn-dirty = false;

  services.getty.autologinUser = "gusjengis";
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  time.timeZone = "America/Los_Angeles";
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
  programs.nix-ld.enable = true;
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
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  services.gnome.core-apps.enable = false;

  # turn on ssh!
  services.openssh = {
    enable = true;
    ports = [
      22
    ];
    settings = {
      X11Forwarding = false;
    };
    # settings = {
    #   # PasswordAuthentication = true;
    #   AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
    #   UseDns = true;
    #   X11Forwarding = false;
    #   # PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    # };
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  fonts.packages = with pkgs; [
    carlito
    commit-mono
    nerd-fonts.meslo-lg
    helvetica-neue-lt-std
  ];
}
