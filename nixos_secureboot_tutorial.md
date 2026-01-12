# NixOS Secure Boot Setup with Lanzaboote

A complete, step-by-step guide to configure UEFI Secure Boot on NixOS using Lanzaboote, with dual-boot Windows support.

## Table of Contents

- [Prerequisites](#prerequisites)
- [What is Secure Boot?](#what-is-secure-boot)
- [What is Lanzaboote?](#what-is-lanzaboote)
- [Before You Start](#before-you-start)
- [Step 1: Verify System Requirements](#step-1-verify-system-requirements)
- [Step 2: Enable Flakes](#step-2-enable-flakes)
- [Step 3: Configure Lanzaboote](#step-3-configure-lanzaboote)
- [Step 4: Generate Secure Boot Keys](#step-4-generate-secure-boot-keys)
- [Step 5: Build and Verify](#step-5-build-and-verify)
- [Step 6: Enroll Keys](#step-6-enroll-keys)
- [Step 7: Enable Secure Boot](#step-7-enable-secure-boot)
- [Troubleshooting](#troubleshooting)
- [Dual Boot with Windows](#dual-boot-with-windows)
- [Maintenance](#maintenance)

---

## Prerequisites

- NixOS installed in UEFI mode
- systemd-boot as bootloader
- Basic understanding of NixOS configuration
- Access to BIOS/UEFI settings
- **IMPORTANT:** Backup of your important data

---

## What is Secure Boot?

UEFI Secure Boot is a security feature that ensures only trusted operating systems can boot on your system. It works by:

1. **Digital signatures**: All boot components (bootloader, kernel, initrd) are cryptographically signed
2. **Chain of trust**: Each component verifies the next before loading it
3. **Key validation**: The UEFI firmware checks signatures against enrolled keys

**Why use Secure Boot?**
- Protection against boot-level malware
- Defense against evil maid attacks
- Required by some software (e.g., Windows 11, some anti-cheat systems)

---

## What is Lanzaboote?

[Lanzaboote](https://github.com/nix-community/lanzaboote) is a Secure Boot implementation specifically designed for NixOS. 

**Key features:**
- Automatic signing of boot files on each rebuild
- Efficient UKI (Unified Kernel Image) handling
- Keeps kernel and initrd separate (saves ESP space)
- Integrates seamlessly with NixOS generations

**Advantages over systemd-stub:**
- Smaller UKI files (kernel and initrd stored separately)
- Better for systems with many generations (limited ESP space)
- NixOS-specific optimizations

---

## Before You Start

### ⚠️ Important Warnings

1. **Backup your Secure Boot keys** - If you lose them and something breaks, you'll need to disable Secure Boot to boot
2. **Set a BIOS password** - Without it, Secure Boot can be easily disabled by an attacker
3. **This is still in development** - Lanzaboote works well but isn't upstreamed to nixpkgs yet
4. **Test with Secure Boot disabled first** - Only enable after everything is working

### What You'll Need

- At least **100GB** of free space (NixOS builds can be large)
- Internet connection (for downloading packages)
- 30-60 minutes of time
- A USB drive or cloud storage for key backup

---

## Step 1: Verify System Requirements

Check that your system meets the requirements:

```bash
bootctl status
```

**Required output:**
```
System:
     Firmware: UEFI 2.XX  # Must be UEFI, not BIOS
  Secure Boot: disabled    # We'll enable this later
 TPM2 Support: yes         # Recommended but not required

Current Boot Loader:
      Product: systemd-boot  # Must be systemd-boot
```

If you see:
- ❌ `Firmware: BIOS` → You need to reinstall in UEFI mode
- ❌ `Product: GRUB` → Switch to systemd-boot first
- ✅ `Firmware: UEFI` + `Product: systemd-boot` → You're ready!

---

## Step 2: Enable Flakes

Lanzaboote requires Nix flakes. Add this to your `configuration.nix`:

```nix
{ config, pkgs, lib, ... }:

{
  # ... your existing configuration ...

  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ... rest of your configuration ...
}
```

Apply the changes:

```bash
sudo nixos-rebuild switch
```

---

## Step 3: Configure Lanzaboote

### Create `flake.nix`

Create `/etc/nixos/flake.nix`:

```nix
{
  description = "NixOS Configuration with Secure Boot";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, ... }: {
    nixosConfigurations.YOUR-HOSTNAME = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager  # If you use home-manager
        lanzaboote.nixosModules.lanzaboote
      ];
    };
  };
}
```

**Replace `YOUR-HOSTNAME`** with your actual hostname (check with `hostname`).

### Update `configuration.nix`

Modify your bootloader configuration:

```nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # Remove: <home-manager/nixos>  # Now comes from flake
  ];

  # Disable systemd-boot (Lanzaboote replaces it)
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  # Configure Lanzaboote
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Optional: Limit boot entries to save space
  boot.loader.systemd-boot.configurationLimit = 5;

  # Install sbctl for key management
  environment.systemPackages = with pkgs; [
    sbctl
    # ... your other packages ...
  ];

  # ... rest of your configuration ...
}
```

### Track files with Git

Flakes only see files tracked by git:

```bash
cd /etc/nixos
sudo git init  # If not already a git repo
sudo git add .
sudo git commit -m "Initial commit with Lanzaboote"
```

---

## Step 4: Generate Secure Boot Keys

Build the system first (Secure Boot still disabled):

```bash
cd /etc/nixos
sudo nixos-rebuild switch --flake .
```

This will take a while on the first run (downloading and compiling).

### Generate keys with sbctl

```bash
sudo sbctl create-keys
```

**Output:**
```
Created Owner UUID xxxxx
Creating secure boot keys...✓
Secure boot keys created!
```

Keys are stored in `/var/lib/sbctl/keys/`.

### Backup your keys (CRITICAL!)

```bash
# Create backup
sudo tar -czf ~/secureboot-keys-backup.tar.gz /var/lib/sbctl/

# Copy to safe location
# - USB drive
# - Cloud storage
# - Another computer
```

**⚠️ DO NOT LOSE THIS BACKUP!** If you lose keys and something breaks, you'll need to disable Secure Boot to recover.

---

## Step 5: Build and Verify

Rebuild the system with Lanzaboote:

```bash
sudo nixos-rebuild switch --flake .
```

**Expected output:**
```
Installing Lanzaboote to "/boot"...
Updating "/boot/EFI/BOOT/BOOTX64.EFI"...
Successfully installed Lanzaboote.
```

### Verify signatures

Check that boot files are signed:

```bash
sudo sbctl verify
```

**You should see:**
```
✓ /boot/EFI/BOOT/BOOTX64.EFI is signed
✓ /boot/EFI/Linux/nixos-generation-X.efi is signed
✓ /boot/EFI/systemd/systemd-bootx64.efi is signed
```

**It's normal to see:**
```
✗ /boot/EFI/Microsoft/Boot/bootmgfw.efi is not signed
```
These Windows files are signed with Microsoft's keys, not yours.

---

## Step 6: Enroll Keys

### Put UEFI in Setup Mode

1. Reboot into BIOS/UEFI settings:
   ```bash
   sudo systemctl reboot --firmware-setup
   ```

2. Navigate to **Security → Secure Boot**

3. Look for options like:
   - "Clear Secure Boot Keys"
   - "Reset to Setup Mode"
   - "Delete All Keys"
   - "Clear Platform Key (PK)"

4. Execute the key clearing option

5. **Save and exit** - System will reboot

### Enroll your keys

Boot back into NixOS and run:

```bash
sudo sbctl enroll-keys --microsoft
```

**The `--microsoft` flag:**
- Keeps Microsoft's keys alongside yours
- **Required for Windows dual-boot**
- Harmless if you don't use Windows

**Output:**
```
Enrolling keys to EFI variables...
With vendor keys from microsoft...✓
Enrolled keys to the EFI variables!
```

### Verify enrollment

```bash
bootctl status
```

Should show:
```
Secure Boot: disabled (setup)
```

The `(setup)` means keys are enrolled but Secure Boot is not yet enabled.

---

## Step 7: Enable Secure Boot

### Enable in BIOS

1. Reboot into BIOS:
   ```bash
   sudo systemctl reboot --firmware-setup
   ```

2. Navigate to **Security → Secure Boot**

3. **Enable Secure Boot**

4. **Save and exit**

### Verify it worked

After booting into NixOS:

```bash
bootctl status
```

**Success looks like:**
```
Secure Boot: enabled (user)
```

The `(user)` indicates custom keys (not factory keys).

---

## Troubleshooting

### Build fails with "No space left on device"

**Problem:** Not enough disk space for builds.

**Solution:**
```bash
# Clean old generations
sudo nix-collect-garbage -d

# Optimize store
sudo nix-store --optimise

# Check space
df -h /
```

Recommendation: Have at least 100GB for NixOS partition.

### "Cannot build cargo" or Rust compilation errors

**Problem:** Version incompatibility with Lanzaboote v0.4.1.

**Solution:** Use the latest version by removing version tag in `flake.nix`:

```nix
lanzaboote = {
  url = "github:nix-community/lanzaboote";  # Remove /v0.4.1
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Then:
```bash
sudo rm flake.lock
sudo nixos-rebuild switch --flake .
```

### "Your system is not in Setup Mode"

**Problem:** Tried to enroll keys without clearing existing keys.

**Solution:** 
1. Reboot into BIOS
2. Clear Secure Boot keys (see Step 6)
3. Boot into NixOS
4. Try `sudo sbctl enroll-keys --microsoft` again

### System won't boot after enabling Secure Boot

**Immediate fix:**
1. Enter BIOS
2. **Disable Secure Boot**
3. Boot into NixOS

**Then debug:**
```bash
# Check what's not signed
sudo sbctl verify

# Check logs
journalctl -b

# Rebuild
sudo nixos-rebuild switch --flake .
```

### "Git tree is dirty" warnings

**Not critical** - Just means uncommitted changes.

**To fix:**
```bash
cd /etc/nixos
sudo git add .
sudo git commit -m "Update configuration"
```

---

## Dual Boot with Windows

### Windows Entry Not Showing

If Windows doesn't appear in systemd-boot menu:

```bash
# Check if Windows bootloader exists
ls /boot/EFI/Microsoft/Boot/bootmgfw.efi

# If it exists, create manual entry
sudo tee /boot/loader/entries/windows.conf << 'EOF'
title Windows
efi /EFI/Microsoft/Boot/bootmgfw.efi
EOF
```

### Testing Windows with Secure Boot

1. Reboot and select Windows in systemd-boot menu
2. Windows should boot normally

**If Windows doesn't boot:**
- Make sure you used `--microsoft` flag when enrolling keys
- Check that Secure Boot is enabled in BIOS

### Accessing Boot Menu

**During boot:**
- NixOS/Windows selection: systemd-boot menu (automatic)
- BIOS boot menu: Usually **F11**, **F12**, or **ESC** (check your motherboard manual)

---

## Maintenance

### After System Updates

Lanzaboote **automatically signs new kernels** on each rebuild. Just:

```bash
sudo nixos-rebuild switch --flake .
```

No manual signing needed!

### Cleaning Old Generations

Your configuration limits to 5 generations, but manually clean with:

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete old ones
sudo nix-collect-garbage -d

# Rebuild to update boot menu
sudo nixos-rebuild switch --flake .
```

### Updating Flake Inputs

Update nixpkgs, lanzaboote, etc:

```bash
cd /etc/nixos
sudo nix flake update
sudo nixos-rebuild switch --flake .
```

### Automatic Garbage Collection

Add to `configuration.nix` for automatic cleanup:

```nix
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 7d";
};
```

### Key Backup Verification

Periodically verify your backup exists and is accessible:

```bash
# Check backup exists
ls -lh ~/secureboot-keys-backup.tar.gz

# Verify contents
tar -tzf ~/secureboot-keys-backup.tar.gz
```

---

## FAQ

### Do I need to re-sign files manually?

**No!** Lanzaboote automatically signs everything during `nixos-rebuild`.

### Can I use this with GRUB?

**No.** Lanzaboote requires systemd-boot. If you need GRUB, look into other Secure Boot solutions.

### Will this work with other distros in multi-boot?

**NixOS:** Yes, fully supported  
**Windows:** Yes, with `--microsoft` flag  
**Other Linux distros:** They need their own Secure Boot configuration

### What if I need to disable Secure Boot temporarily?

Just disable it in BIOS. Your keys remain enrolled. Re-enable anytime.

### How do I know if Secure Boot is actually working?

```bash
bootctl status | grep "Secure Boot"
```

Should show: `Secure Boot: enabled (user)`

### Can I use this on a laptop with existing Secure Boot keys?

Yes, but you need to clear the factory keys first (Setup Mode). Your backup is crucial here.

---

## Additional Resources

- [Lanzaboote GitHub](https://github.com/nix-community/lanzaboote)
- [Lanzaboote Documentation](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md)
- [NixOS Wiki - Secure Boot](https://nixos.wiki/wiki/Secure_Boot)
- [sbctl GitHub](https://github.com/Foxboron/sbctl)

---

## Credits

This guide was created based on real-world setup experience and community documentation.

**Contributing:** Found an error or have improvements? Open an issue or PR!

---

## License

This guide is released under CC0 (Public Domain). Use it freely!

---

**Happy Secure Booting!** 🔒🚀