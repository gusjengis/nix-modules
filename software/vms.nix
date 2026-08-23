{
  config,
  lib,
  pkgs,
  ...
}:
{

  options.virtual-machines = {
    enable = lib.mkEnableOption "enables virtual-machines";
    vfioPciIds = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "PCI vendor and device IDs reserved for VFIO passthrough";
    };
    fileSharing = {
      enable = lib.mkEnableOption "bidirectional file sharing with a Windows VM";
      windowsAddress = lib.mkOption {
        type = lib.types.str;
        default = "192.168.122.18";
        description = "Static IPv4 address of the Windows VM";
      };
      windowsShare = lib.mkOption {
        type = lib.types.str;
        default = "WindowsRoot";
        description = "Windows SMB share mounted at /mnt/windows";
      };
      credentialsFile = lib.mkOption {
        type = lib.types.str;
        default = "/home/gusjengis/.config/secrets/windows-smb-credentials";
        description = "Path to the root-readable Windows SMB credentials file";
      };
    };
    windowsRdp = {
      enable = lib.mkEnableOption "autostart and tailnet routing for a Windows VM";
      vmName = lib.mkOption {
        type = lib.types.str;
        default = "win11";
        description = "libvirt domain name for the Windows VM";
      };
      address = lib.mkOption {
        type = lib.types.str;
        default = "192.168.122.18";
        description = "Static IPv4 address advertised to the tailnet";
      };
    };
  };

  config = lib.mkIf config.virtual-machines.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    programs.virt-manager.enable = true;

    environment.systemPackages =
      (with pkgs; [
        qemu_kvm
        virt-manager
        virt-viewer
        libvirt
        OVMF
        spice-gtk
      ])
      ++ lib.optionals config.virtual-machines.fileSharing.enable (
        with pkgs;
        [
          cifs-utils
          samba
        ]
      );

    users.users.gusjengis.extraGroups = [
      "libvirtd"
      "kvm"
    ];

    boot.kernelParams = lib.mkIf (config.virtual-machines.vfioPciIds != [ ]) [
      "intel_iommu=on"
      "iommu=pt"
      "vfio-pci.ids=${lib.concatStringsSep "," config.virtual-machines.vfioPciIds}"
    ];
    boot.initrd.kernelModules = lib.mkIf (config.virtual-machines.vfioPciIds != [ ]) [
      "vfio"
      "vfio_pci"
      "vfio_iommu_type1"
    ];

    services.samba = lib.mkIf config.virtual-machines.fileSharing.enable {
      enable = true;
      openFirewall = false;
      nmbd.enable = false;
      winbindd.enable = false;
      settings = {
        global = {
          "server role" = "standalone server";
          "security" = "user";
          "map to guest" = "Never";
          "server min protocol" = "SMB3_00";
          "smb ports" = "445";
          "disable netbios" = "yes";
          "hosts allow" = "127.0.0.1 192.168.122.0/24";
          "hosts deny" = "0.0.0.0/0";
        };
        NixOSRoot = {
          path = "/";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "valid users" = "gusjengis";
          "force user" = "gusjengis";
          "force group" = "users";
          "create mask" = "0644";
          "directory mask" = "0755";
        };
      };
    };

    networking.firewall.interfaces.virbr0.allowedTCPPorts =
      lib.mkIf config.virtual-machines.fileSharing.enable
        [ 445 ];

    boot.supportedFilesystems = lib.mkIf config.virtual-machines.fileSharing.enable [ "cifs" ];

    services.tailscale.useRoutingFeatures = lib.mkIf config.virtual-machines.windowsRdp.enable "server";

    systemd.services.windows-vm-autostart = lib.mkIf config.virtual-machines.windowsRdp.enable {
      description = "Start the Windows VM";
      after = [ "libvirtd.service" ];
      requires = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        state="$(${lib.getExe' pkgs.libvirt "virsh"} --connect qemu:///system domstate ${lib.escapeShellArg config.virtual-machines.windowsRdp.vmName})"
        if [ "$state" != running ]; then
          ${lib.getExe' pkgs.libvirt "virsh"} --connect qemu:///system start ${lib.escapeShellArg config.virtual-machines.windowsRdp.vmName}
        fi
      '';
    };

    systemd.services.tailscale-advertise-windows-vm =
      lib.mkIf config.virtual-machines.windowsRdp.enable
        {
          description = "Advertise the Windows VM to the tailnet";
          after = [
            "tailscaled.service"
            "tailscale-autoconnect.service"
            "windows-vm-autostart.service"
          ];
          requires = [ "tailscaled.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.tailscale}/bin/tailscale set --advertise-routes=${config.virtual-machines.windowsRdp.address}/32";
            Restart = "on-failure";
            RestartSec = 10;
          };
        };

    fileSystems."/mnt/windows" = lib.mkIf config.virtual-machines.fileSharing.enable {
      device = "//${config.virtual-machines.fileSharing.windowsAddress}/${config.virtual-machines.fileSharing.windowsShare}";
      fsType = "cifs";
      options = [
        "credentials=${config.virtual-machines.fileSharing.credentialsFile}"
        "uid=1000"
        "gid=100"
        "file_mode=0644"
        "dir_mode=0755"
        "vers=3.1.1"
        "seal"
        "cache=none"
        "noperm"
        "rw"
        "_netdev"
        "nofail"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=300"
        "x-systemd.mount-timeout=10s"
      ];
    };
  };
}
