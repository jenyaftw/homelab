{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.kernelParams = [ "toram" ];

  networking.useDHCP = true;

  users.users.jenya = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "nixos";
  };

  security.sudo.enable = true;

  fileSystems."/persist" = {
    device = "/dev/disk/by-label/PERSIST";
    fsType = "ext4";
    neededForBoot = false;
  };

  environment.persistence."/persist" = {
    directories = [
      "/etc/nixos"
      "/var/lib"
    ];

    files = [
      "/etc/machine-id"
    ];

    users.jenya = {
      directories = [
        ".ssh"
        ".local"
        "Documents"
      ];
      files = [ ".bash_history" ];
    };
  };

  environment.etc."persist.sh".source = ./scripts/persist.sh;

  systemd.services.create-persist = {
    description = "Auto-create /persist partition on first boot";
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      ConditionPathExists = "!/dev/disk/by-label/PERSIST";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [ "/etc/persist.sh" ];
    };
  };
}
