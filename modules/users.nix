{ config, pkgs, lib, ... }:

{
  # System user configuration
  users.users.anorak = {
    isNormalUser = true;
    description = "Anorak";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
    packages = with pkgs; [ kdePackages.kate ];
  };
}
