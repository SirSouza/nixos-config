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
    packages = with pkgs; [ ];
  };

  # Home Manager configuration
  home-manager.users.anorak = import ../home.nix;
}
