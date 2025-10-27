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
}
