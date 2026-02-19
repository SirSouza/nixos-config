{ config, pkgs, lib, ... }:

{
  # Firefox
  programs.firefox.enable = true;

  # Fish terminal
  programs.fish.enable = true;

  # Env setup
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Non-nix binaries
  programs.nix-ld.enable = true;

  # Index
  programs.nix-index.enable = true;

  # OBS-Studio and plugins
  programs.obs-studio = {
    enable = true;

    # Optional Nvidia hardware acceleration
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

  # Enable FUSE
  programs.fuse.enable = true;
  programs.fuse.userAllowOther = true;

  # Autorun Appimage
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}