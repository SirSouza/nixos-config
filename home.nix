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

  # Enable dconf (required for the configurations bellow)
  dconf.enable = true;

  dconf.settings = {
    # Interface and fonts
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      font-name = "JetBrainsMono Nerd Font 11";
      document-font-name = "JetBrainsMono Nerd Font 11";
      monospace-font-name = "JetBrainsMono Nerd Font 11";
      icon-theme = "Gruvbox-Plus-Dark";
      gtk-theme = "Gruvbox-Dark";
    };

    # Auto cleaning and Privacy
    "org/gnome/desktop/privacy" = {
      remember-recent-files = true;
      recent-files-max-age = 30;
      remove-old-trash-files = true;
      remove-old-temp-files = true;
      old-files-age = 30;
    };
  };

  /*
    gtk = {
      enable = true;
      theme = {
        name = "Gruvbox-Dark"
      };
      icon-theme = {
        name = "Gruvbox-Plus-Dark";
        package = pkgs.gruvbox-plus-icons;
      };
      font {
      name = "JetBrainsMono Nerd Font";
      size = 11;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  */

  # Enviroment Variables for GTK
  home.sessionVariables = {
    GTK_THEME = "Gruvbox-Dark";
  };

  home.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];
}