# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./disks.nix
      ./modules/packages.nix
      ./modules/boot.nix
      ./modules/desktop.nix
      ./modules/system.nix
      ./modules/hardware.nix
      ./modules/services.nix
      ./modules/users.nix
      ./modules/programs.nix
    ];

}
