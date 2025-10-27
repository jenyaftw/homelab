{ config, pkgs, ... }:

{
  ########################################
  # Boot setup (USB + load to RAM)
  ########################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "toram" ];  # copies rootfs to RAM
  boot.supportedFilesystems = [ "vfat" "ext4" "xfs" "zfs" ];

  ########################################
  # Host + networking
  ########################################
  networking.hostName = "serenity-node";
  networking.useDHCP = true;

  ########################################
  # User configuration
  ########################################
  users.users.jenya = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];    # sudo
    initialPassword = "nixos";    # change after boot
  };

  security.sudo.enable = true;

  ########################################
  # Minimal environment
  ########################################
  environment.systemPackages = with pkgs; [ vim htop ];

  ########################################
  # Locale / time
  ########################################
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
}
