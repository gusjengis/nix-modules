{
  config,
  lib,
  pkgs,
  ...
}:
{

  options = {
    virtual-machines.enable = lib.mkEnableOption "enables virtual-machines";
  };

  config = lib.mkIf config.virtual-machines.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
      qemu_kvm
      virt-manager
      virt-viewer
      libvirt
      OVMF
      spice-gtk
    ];

    users.users.gusjengis.extraGroups = [
      "libvirtd"
      "kvm"
    ];
  };
}
