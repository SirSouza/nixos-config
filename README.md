# 🚀 My NixOS Config

> *"Humanity questioned. The computer calculated. Millions of years passed. The answer echoed through the cosmos: '42'. Meanwhile, in the basement, a dev discovered that `nixos-rebuild switch` solves almost everything. Almost."*

Welcome to my NixOS configuration! This is my personal setup running GNOME with a Gruvbox theme.

---

## 📊 The Setup

### Hardware
- **CPU:** AMD Ryzen 5 5600X 
- **GPU:** NVIDIA GeForce GTX 1060 3GB *(yes, it’s still alive and fighting bravely in 2026)*
- **RAM:** 32GB (because closing Chrome tabs is not an option)
- **Storage:** 3TB total (1TB SSD + 2× 1TB HDD)
- **Motherboard:** ASRock B450M Steel Legend

### Software
- **OS:** NixOS 26.05 (Yarara)
- **Kernel:** Linux 6.18.4 (always latest)
- **DE:** GNOME 49 (Wayland)
- **DM:** SDDM with Wayland support
- **Shell:** Fish (life is too short for bash)

---

## ✨ Key Features

### 🎨 Visual
- **Gruvbox theme** everywhere (GTK3, GTK4, GNOME)
- **JetBrains Mono Nerd Font** — because developers need style
- GNOME extensions: Dash to Dock, User Themes
- SDDM with Breeze theme (can be changed later)

### 🛠️ Development
- **PostgreSQL 15** configured in DEV mode (trust auth, no password — **DO NOT USE IN PRODUCTION**)
- Pre-created databases: `mydatabase` and `anorak`
- **direnv + nix-direnv** for isolated development environments
- **Node.js** (whether we like it or not, JavaScript runs the world)
- **VS Code** as the main IDE 

### 🎮 Apps & Productivity
- **Ghostty** (modern and fast terminal)
- **Firefox** (pre-installed)
- **Flatpak** enabled with Flathub 
- **Discord** for communication
- **Spotify** for coding soundtracks
- **Obsidian** to organize mental chaos
- **VLC** — it plays everything

### 🐟 Fish Shell Setup
Configured plugins:
- `done` — notifications when long-running commands finish
- `fzf-fish` — fuzzy search everywhere
- `forgit` — interactive and clean Git workflow
- `hydro` — minimal and fast prompt
- `grc` — command output colorization

### 🎯 NVIDIA Drivers
- Proprietary drivers (stable)
- Modesetting enabled
- 32-bit support (for legacy games)

---

## 🔐 Secure Boot with Lanzaboote (Flakes)

This configuration uses **lanzaboote** to enable **UEFI Secure Boot** while keeping the system fully declarative and compatible with **Nix flakes**.

### Why Lanzaboote?
- Works seamlessly with **systemd-boot**
- Fully declarative Secure Boot setup
- Ideal for **flake-based** NixOS systems
- Automatically signs kernels and boot artifacts

### Key Characteristics
- Secure Boot **enabled and enforced**
- Custom Machine Owner Key (MOK) managed by NixOS
- Compatible with system rollbacks and generations
- No shim required

### High-Level Setup Overview
- Secure Boot keys are generated and managed declaratively
- systemd-boot is used as the bootloader
- lanzaboote signs EFI binaries automatically during rebuilds
- Flakes are used as the entry point for system configuration

### Notes
- After initial key enrollment, Secure Boot remains enabled across rebuilds
- If firmware settings are reset, keys may need to be re-enrolled
- This setup is ideal for laptops and desktops that require Secure Boot (e.g. dual-boot with Windows)

> ⚠️ Important: Once Secure Boot is enabled and enforced, unsigned kernels **will not boot**.

---

## 📁 Repository Structure

```
.
├── configuration.nix           # Main system configuration
├── hardware-configuration.nix  # Auto-generated hardware config
├── disks.nix                   # Disk layout (create based on the example)
└── README.md                   # You are here 👋
```

---

## 🚀 How to Use

### Fresh Installation

1. Clone this repository:
```bash
git clone https://github.com/SirSouza/nixos-config.git /etc/nixos
cd /etc/nixos
```

2. **IMPORTANT:** Create your `disks.nix` according to your system (or copy from the example)

3. Generate your hardware config:
```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

4. Edit `configuration.nix` and adjust:
- Username (replace `anorak` with yours)
- Hostname
- PostgreSQL databases (if needed)

5. Rebuild the system:
```bash
sudo nixos-rebuild switch
```
6. With flakes:
- I strongly recommend using aliases for this.
```bash
cd /etc/nixos
sudo nixos-rebuild switch --flake .#you
```
- From anywhere in your NixOS
```bash
sudo nixos-rebuild switch --flake /etc/nixos
```


---

### Updating the System

```bash
# Update channels
sudo nix-channel --update

# Rebuild
sudo nixos-rebuild switch 
or 
sudo nixos-rebuild switch --flake /etc/nixos # for flakes
# Or everything at once
sudo nix-channel --update && sudo nixos-rebuild switch
```

---

### Cleaning Old Generations

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete old generations (keeps the latest ones in the boot menu)
sudo nix-collect-garbage -d

# Or delete specific generations
sudo nix-env --delete-generations 1 2 3 --profile /nix/var/nix/profiles/system
```

---

## 🔧 Interesting Customizations

### Home Manager
Home Manager is integrated into NixOS to manage user-level configuration. All Gruvbox theming, fonts, and GNOME settings live under `home-manager.users.anorak`.

### PostgreSQL in DEV Mode
PostgreSQL is configured with **trust authentication** (no password). Perfect for local development — **never use this in production or on exposed systems**.

### Flatpak Auto Setup
A systemd service automatically adds the Flathub repository on first boot.

### Boot Limit
The bootloader keeps only the last 4 system generations (configurable via `boot.loader.systemd-boot.configurationLimit`).

---

## 💡 Tips

- **NTFS Support:** Enabled for Windows dual-boot setups
- **Kernel:** Always latest (switch to LTS if you prefer stability)
- **NVIDIA:** If suspend/hibernate misbehaves, enable `powerManagement.enable = true`
- **Wayland:** Works flawlessly with GNOME and recent NVIDIA drivers

---

## 🤝 Contributing

Found something interesting or have suggestions? Feel free to open an issue or PR. This is a personal project, but I love learning from the community.

---

## 📝 Notes

- This config is personal but public to help other NixOS users
- Based on NixOS 26.05 (may require adjustments for other versions)
- Tested only on my hardware (but should work elsewhere with minimal changes)

---

## 📜 License

[![CC0](https://licensebuttons.net/p/zero/1.0/88x31.png)](https://creativecommons.org/publicdomain/zero/1.0/)
This configuration is released under CC0 (Public Domain). Use it freely!

---

*Made with ❤️ and lots of coffee ☕ on NixOS*

**P.S.:** If you’re reading this thinking “a GTX 1060 in 2026?”, yes — it’s still holding up. Don’t judge. 😅
**P.S. pt2:** I'm continuously  updating this documentation and the configuration as i learn about NixOS.

