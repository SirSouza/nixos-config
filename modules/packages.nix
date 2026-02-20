{ config, pkgs, lib, ... }:

{ 

 # Allow unfree packages
 nixpkgs.config.allowUnfree = true;


 # System Packages
 environment.systemPackages = with pkgs; [


 # Development tools
    vim
    ripgrep
    nixd
    nixfmt
    clang-tools
    lua-language-server
    pyright
    rust-analyzer
    rustup
    gcc
    binutils
    gnumake
    nodejs
    pnpm
    yarn
    git
    vscode
    openssl
    pkg-config
    helix

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

   # KDE
   kdePackages.kwallet
   kdePackages.kwalletmanager

   # Media
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    vlc
    spotify
    discord
    element
    obsidian

   # Utilities
    sbctl
    ntfs3g
    gparted
    appimage-run
    fuse
    fuse2
    blender
    unzip
    nps
    numix-cursor-theme
    (brave.override {
  commandLineArgs = "--ozone-platform=x11";
})

  ];

}
