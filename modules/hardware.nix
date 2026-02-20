{ config, pkgs, lib, ... }:

{
  # OpenGL/Graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
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
}
