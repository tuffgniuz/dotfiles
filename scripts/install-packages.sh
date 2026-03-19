#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACMAN_PACKAGES_FILE="$DOTFILES_DIR/packages/pacman.txt"
AUR_PACKAGES_FILE="$DOTFILES_DIR/packages/aur.txt"

NOCONFIRM=""
if [ "${1:-}" = "-y" ] || [ "${1:-}" = "--noconfirm" ]; then
  NOCONFIRM="--noconfirm"
fi

install_pacman_packages() {
  if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman not found; skipping official package install."
    return
  fi

  mapfile -t packages < <(grep -vE '^\s*($|#)' "$PACMAN_PACKAGES_FILE")
  if [ "${#packages[@]}" -eq 0 ]; then
    return
  fi

  # shellcheck disable=SC2086
  sudo pacman -S --needed ${NOCONFIRM} "${packages[@]}"
}

install_aur_packages() {
  mapfile -t packages < <(grep -vE '^\s*($|#)' "$AUR_PACKAGES_FILE")
  if [ "${#packages[@]}" -eq 0 ]; then
    return
  fi

  if ! command -v paru >/dev/null 2>&1; then
    echo "::error::paru not found, but is required to install AUR packages."
    exit 1
  fi

  # shellcheck disable=SC2086
  paru -S --needed ${NOCONFIRM} "${packages[@]}"
}

install_pacman_packages
install_aur_packages
