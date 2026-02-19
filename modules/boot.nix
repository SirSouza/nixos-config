{ config, pkgs, lib, ... }:

{
  # Bootloader
  #boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 130;
  boot.supportedFilesystems = [ "ntfs" ];

  # Lanzaboote for Secure Boot
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Generation limit
  boot.loader.systemd-boot.configurationLimit = 3;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
}