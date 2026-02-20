{ config, pkgs, lib, ... }:


{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.timeout = 130;
  boot.supportedFilesystems = [ "ntfs" ];

  # Generation limit
  boot.loader.systemd-boot.configurationLimit = 3;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
