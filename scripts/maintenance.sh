#!/usr/bin/env bash

set -e

FLAKE_DIR="/etc/nixos"

echo "======================================"
echo "Starting Maintenance of NixOS"
echo "======================================"

# 1️⃣ Update inputs
echo
echo "Updating flake inputs..."
cd "$FLAKE_DIR"
nix flake update

# 2️⃣ Rebuild system
echo
echo "Rebuild dsystem..."
sudo nixos-rebuild switch --flake "$FLAKE_DIR"

# 3️⃣ Otimização da store
echo
echo "Optimizing Nix Store (deduplication)"
sudo nix-store --optimise

# 4️⃣ Clean old generations
echo
echo "Removing old system generations..."
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations old

# 5️⃣ Garbage Collection
echo
echo "Garbage collection..."
sudo nix-collect-garbage --delete-old

# 6️⃣ Store integrity
echo
echo "Verifying store integridy..."
sudo nix-store --verify --repair

echo
echo "Maintenance completed successfully"
echo "======================================"
