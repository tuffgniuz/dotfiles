#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACMAN_PACKAGES_FILE="$DOTFILES_DIR/packages/pacman.txt"
AUR_PACKAGES_FILE="$DOTFILES_DIR/packages/aur.txt"

install_pacman_packages() {
  if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman not found; skipping official package install."
    return
  fi

  mapfile -t packages < <(grep -vE '^\s*($|#)' "$PACMAN_PACKAGES_FILE")
  if [ "${#packages[@]}" -eq 0 ]; then
    return
  fi

  sudo pacman -S --needed "${packages[@]}"
}

install_aur_packages() {
  if ! command -v paru >/dev/null 2>&1; then
    echo "paru not found; skipping AUR package install."
    return
  fi

  mapfile -t packages < <(grep -vE '^\s*($|#)' "$AUR_PACKAGES_FILE")
  if [ "${#packages[@]}" -eq 0 ]; then
    return
  fi

  paru -S --needed "${packages[@]}"
}

install_pacman_packages
install_aur_packages
