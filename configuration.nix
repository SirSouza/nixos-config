
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disks.nix 
    ./modules/boot.nix
    ./modules/system.nix
    ./modules/hardware.nix
    ./modules/desktop.nix
    ./modules/services.nix
    ./modules/virtualization.nix
    ./modules/programs.nix
    ./modules/users.nix
    ./modules/packages.nix
  ];
}
