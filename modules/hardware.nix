{ config, pkgs, lib, ... }:

{
  # OpenGL/Graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # NVIDIA Configuration
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable X11 and video settings
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  # Sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}