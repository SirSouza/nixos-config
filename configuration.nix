# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

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
    ./disks.nix # Local file (look disks.nix.example)
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 120;
  boot.supportedFilesystems = [ "ntfs" ];

  # Lanzaboote for Secure Boot
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Generation limit
  boot.loader.systemd-boot.configurationLimit = 3;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "NixOS";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
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

  # Enables OpenGL/Graphics support.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable X11 and video settings.
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  # NVIDIA Configuration
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # SDDM as a display manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "where_is_my_sddm_theme";
    settings = {
      Wayland = {
        CompositorCommand = "${pkgs.weston}/bin/weston --shell=kiosk -c /etc/sddm-weston.ini";
      };
    };
  };
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
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
  systemd.tmpfiles.rules = [
    "d /var/lib/sddm/.config 0711 sddm sddm - -"
    "f /var/lib/sddm/.config/kwinoutputconfig.json 0644 sddm sddm - -"
  ];

  # Enable the GNOME Desktop Environment
  services.desktopManager.gnome.enable = true;
  programs.dconf.enable = true;
  services.dbus.packages = [ pkgs.dconf ];
  environment.sessionVariables = {
  GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
};
  # Printing
  services.printing.enable = true;
  
  # Fish terminal
  programs.fish.enable = true;

  # env setup
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  
  #nom-nix binaries
  programs.nix-ld.enable = true;

  # Index
  programs.nix-index.enable = true;
  
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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

  # --- System user configuration ---
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

  # --- HOME MANAGER ---
  home-manager.users.anorak =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      gruvbox-theme-custom = pkgs.gruvbox-gtk-theme.override {
        tweakVariants = [ "macos" ];
        colorVariants = [ "dark" ];
      };
    in
    {
      home.stateVersion = "25.11";
      home.enableNixpkgsReleaseCheck = false;

      # Enable dconf (required for the configurations below)
      dconf.enable = true;

      dconf.settings = {
        # Interface and Font Settings
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          font-name = "JetBrainsMono Nerd Font 11";
          document-font-name = "JetBrainsMono Nerd Font 11";
          monospace-font-name = "JetBrainsMono Nerd Font 11";
          icon-theme = "Gruvbox-Plus-Dark";
          gtk-theme = "Gruvbox-Dark-macos";
        };
        # Automatic cleaning and Privacy
        "org/gnome/desktop/privacy" = {
          remember-recent-files = true;
          recent-files-max-age = 30;
          remove-old-trash-files = true;
          remove-old-temp-files = true;
          old-files-age = 30;

        };
      };

      #  GTK Settings
      gtk = {
        enable = true;
        theme = {
          name = "Gruvbox-Dark-macos";
          package = gruvbox-theme-custom;
        };
        iconTheme = {
          name = "Gruvbox-Plus-Dark";
          package = gruvbox-theme-custom;
        };
      };

      # symbolyc links for GTK4
      home.file.".themes/Gruvbox-Dark-macos".source =
        "${gruvbox-theme-custom}/share/themes/Gruvbox-Dark-macos";
      home.file.".local/share/icons/Gruvbox-Plus-Dark".source =
        "${pkgs.gruvbox-plus-icons}/share/icons/Gruvbox-Plus-Dark";

      xdg.configFile = {
        "gtk-3.0/settings.ini".text = ''
          [Settings]
          gtk-theme-name=Gruvbox-Dark-macos
          gtk-icon-theme-name=Gruvbox-Plus-Dark
          gtk-font-name=JetBrainsMono Nerd Font 11
          gtk-cursor-theme-name=Adwaita
          gtk-application-prefer-dark-theme=1
        '';
        "gtk-4.0/assets".source = "${gruvbox-theme-custom}/share/themes/Gruvbox-Dark-macos/gtk-4.0/assets";
        "gtk-4.0/gtk.css".source =
          "${gruvbox-theme-custom}/share/themes/Gruvbox-Dark-macos/gtk-4.0/gtk.css";
        "gtk-4.0/gtk-dark.css".source =
          "${gruvbox-theme-custom}/share/themes/Gruvbox-Dark-macos/gtk-4.0/gtk-dark.css";
      };

      # Enviroment viariables for GTK
      home.sessionVariables = {
        GTK_THEME = "Gruvbox-Dark-macos";
      };

      home.packages = with pkgs; [
        jetbrains-mono
        nerd-fonts.jetbrains-mono
      ];
    };

  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;
  services.flatpak.enable = true;

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # OBS-Studio and plugins Settings
  programs.obs-studio = {
    enable = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
    ];
  };

  # VM configuration
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
    onBoot = "start";
    onShutdown = "shutdown";
  };
  programs.virt-manager.enable = true;

  #Network configuration
  networking.firewall.checkReversePath = false;
  environment.etc."libvirt/qemu/networks/default.xml".text = ''
    <network>
      <name>default</name>
      <forward mode='nat'/>
      <bridge name='virbr0' stp='on' delay='0'/>
      <ip address='192.168.122.1' netmask='255.255.255.0'>
        <dhcp>
          <range start='192.168.122.2' end='192.168.122.254'/>
        </dhcp>
      </ip>
    </network>
  '';
  
  
  # Jellyfin configuration
  services.jellyfin = {
   enable = true;
   openFirewall = true;
   user = "anorak";
  };
  
  nixpkgs.config.packageOverrides = pkgs: {
    cool-retro-term = pkgs.symlinkJoin {
      name = "cool-retro-term";
      paths = [ pkgs.cool-retro-term ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/cool-retro-term \
          --set GSETTINGS_SCHEMA_DIR "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas"
      '';
    };
  };

  # Enable FUSE
  programs.fuse.enable = true;
  programs.fuse.userAllowOther = true;
  
  # Autorun Appimage
  programs.appimage = {
  enable = true;
  binfmt = true;
  };
  
  # Packages
  environment.systemPackages = with pkgs; [
  (makeDesktopItem {
    name = "Anytype";
    desktopName = "Anytype";
    exec = "appimage-run /home/anorak/Appimages/Anytype-0.53.1.AppImage";
    icon = "/home/anorak/Appimages/anytype.png";
    comment = "Uma descrição curta";
    categories = [ "Utility" ];
  })
  appimage-run
  fuse
  fuse2
  cool-retro-term
  jellyfin-media-player
  jellyfin
  jellyfin-web
  jellyfin-ffmpeg
  wineWowPackages.waylandFull
  lutris
  pcsx2
  rpcs3
  gsettings-desktop-schemas
  glib
  dconf
  btop
  cmatrix
  fastfetch
  libsForQt5.qt5.qtgraphicaleffects
  libsForQt5.qt5.qtquickcontrols2
  libsForQt5.qt5.qtsvg
  where-is-my-sddm-theme
  weston
  kdePackages.plasma-desktop
  kdePackages.sddm-kcm
  (python3.withPackages (
    python-pkgs: with python-pkgs; [
      pandas
      requests
      rpy2
    ]
  ))
  (bottles.override { removeWarningPopup = true; })
  sbctl
  ntfs3g
  gnome-extension-manager
  gnome-software
  gnome-tweaks
  gnomeExtensions.user-themes
  gnomeExtensions.blur-my-shell
  gnomeExtensions.dash-to-dock
  gtk-engine-murrine
  gnome-themes-extra
  gruvbox-gtk-theme
  gruvbox-plus-icons
  sassc
  inter
  wget
  git
  grc
  vscode
  steam
  vim
  neovim
  nixfmt
  postgresql
  ghostty
  discord
  element
  spotify
  vlc
  obsidian
  nodejs
  yarn
  fish
  fishPlugins.done
  fishPlugins.fzf-fish
  fishPlugins.forgit
  fishPlugins.hydro
  fishPlugins.grc
  nmap
  gparted
  rustup
  ];
  environment.pathsToLink = [ 
  "/share/applications"
  "/share/gsettings-schemas"
  ];
  system.stateVersion = "25.11";
}
