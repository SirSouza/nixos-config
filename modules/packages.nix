{ config, pkgs, lib, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Package overrides
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

  # System packages
  environment.systemPackages = with pkgs; [
    # Editors
    nerd-fonts.zed-mono
    zed-editor
    helix
    vim
    neovim

    # Development tools
    ripgrep
    nixd
    nixfmt
    clang-tools
    lua-language-server
    pyright
    rustup
    gcc
    binutils
    gnumake
    nodejs
    yarn
    git
    vscode

    # Databases
    postgresql

    # Terminal
    ghostty
    quickshell
    cool-retro-term
    btop
    cmatrix
    fastfetch
    fish
    fishPlugins.done
    fishPlugins.fzf-fish
    fishPlugins.forgit
    fishPlugins.hydro
    fishPlugins.grc
    grc
    wget
    nmap

    # Python with packages
    (python3.withPackages (
      python-pkgs: with python-pkgs; [
        pandas
        requests
        rpy2
      ]
    ))

    # Media
    jellyfin
    jellyfin-desktop
    jellyfin-web
    jellyfin-ffmpeg
    vlc
    spotify
    discord
    element
    obsidian

    # Gaming
    wineWow64Packages.waylandFull
    lutris
    pcsx2
    rpcs3
    steam
    (bottles.override { removeWarningPopup = true; })

    # GNOME
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
    gsettings-desktop-schemas
    glib
    dconf
    sassc
    inter

    # Qt/KDE (for SDDM)
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtsvg
    where-is-my-sddm-theme
    (catppuccin-sddm.override {
    flavor = "mocha";
    accent = "mauve";
    font = "Noto Sans";
    fontSize = "9";
    loginBackground = true;
  })
    weston
    kdePackages.plasma-desktop
    kdePackages.sddm-kcm

    # Utilities
    sbctl
    ntfs3g
    gparted
    appimage-run
    fuse
    fuse2
    blender

    # Custom desktop item for Anytype
    (makeDesktopItem {
      name = "Anytype";
      desktopName = "Anytype";
      exec = "appimage-run /home/anorak/Appimages/Anytype-0.53.1.AppImage";
      icon = "/home/anorak/Appimages/anytype.png";
      comment = "Uma descrição curta";
      categories = [ "Utility" ];
    })
  ];
}
