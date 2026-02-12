{
  config,
  pkgs,
  lib,
  ...
}:

{
  # SDDM as display manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha-mauve";
    package = pkgs.kdePackages.sddm;
    settings = {
      Wayland = {
        CompositorCommand = "${pkgs.weston}/bin/weston --shell=kiosk -c /etc/sddm-weston.ini";
      };
    };
  };

  # Qt configuration
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  # SDDM Weston configuration
  environment.etc."sddm-weston.ini".text = ''
    [output]
    name=DP-2
    mode=1920x1080@180.003
    primary=true

    [output]
    name=DP-1
    mode=1920x1080@50.000
    transform=90
  '';

  # SDDM tmpfiles
  systemd.tmpfiles.rules = [
    "d /var/lib/sddm/.config 0711 sddm sddm - -"
    "f /var/lib/sddm/.config/kwinoutputconfig.json 0644 sddm sddm - -"
  ];

  # GNOME Desktop Environment
  services.desktopManager.gnome.enable = true;
  programs.dconf.enable = true;
  services.dbus.packages = [ pkgs.dconf ];

  # Environment variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Path links
  environment.pathsToLink = [
    "/share/applications"
    "/share/gsettings-schemas"
  ];
}
