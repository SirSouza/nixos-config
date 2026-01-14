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
    theme = "breeze";
  };

  # Enable the GNOME Desktop Environment
  services.desktopManager.gnome.enable = true;

  # Printing
  services.printing.enable = true;

  programs.fish.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

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
          package = pkgs.gruvbox-plus-icons;
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

  # Packages
  environment.systemPackages = with pkgs; [
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
    vesktop
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
    fish
    fishPlugins.done
    fishPlugins.fzf-fish
    fishPlugins.forgit
    fishPlugins.hydro
    fishPlugins.grc
    nmap
    gparted    
  ];
  environment.pathsToLink = [ "/share/applications" ];
  system.stateVersion = "25.11";
}
