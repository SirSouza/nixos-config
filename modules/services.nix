{ config, pkgs, lib, ... }:

{
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # PostgreSQL configured for DEV (trust, no password)
  # DO NOT USE IN PRODUCTION
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    ensureDatabases = [
      "mydatabase"
      "anorak"
    ];
    ensureUsers = [
      {
        name = "anorak";
        ensureDBOwnership = true;
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser     auth-method
      local all       all        trust
      host  all       all        127.0.0.1/32   trust
      host  all       all        ::1/128        trust
    '';
  };

  # Jellyfin configuration
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "anorak";
  };

  # Flatpak
  services.flatpak.enable = true;

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
