{ config, pkgs, lib, ... }:

{
  # Nix settings
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Hostname and networking
  networking.hostName = "NixOS";
  networking.networkmanager.enable = true;
  networking.firewall.checkReversePath = false;

  # Time zone
  time.timeZone = "America/Sao_Paulo";

  # Locale settings
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Japonese, Chinese and Corean fonts support
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-lgc-plus
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
      source-han-sans
      source-han-serif
      nanum
    ];

    fontconfig.enable = true;
  };

  # System version
  system.stateVersion = "25.11";
}