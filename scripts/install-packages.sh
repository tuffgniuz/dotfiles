#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACMAN_PACKAGES_FILE="$DOTFILES_DIR/packages/pacman.txt"
AUR_PACKAGES_FILE="$DOTFILES_DIR/packages/aur.txt"
PARU_REPO_URL="${PARU_REPO_URL:-https://github.com/Morganamilo/paru.git}"
PACMAN_BOOTSTRAP_PACKAGES=(base-devel git)
PARU_SOURCE_BOOTSTRAP_PACKAGES=(rust)
SUDO_CMD=()
PACMAN_ARGS=(--needed)
PARU_ARGS=(--needed)
PACMAN_PACKAGES=()
AUR_PACKAGES=()

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -y|--noconfirm)
        PACMAN_ARGS+=(--noconfirm)
        PARU_ARGS+=(--noconfirm)
        ;;
      -h|--help)
        cat <<'EOF'
Usage: ./scripts/install-packages.sh [options]

Options:
  -y, --noconfirm    Install packages without prompting
  -h, --help         Show this help message
EOF
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
    esac
    shift
  done
}

read_package_file() {
  local file_path="$1"

  if [ ! -f "$file_path" ]; then
    return
  fi

  grep -vE '^\s*($|#)' "$file_path" || true
}

load_package_lists() {
  mapfile -t PACMAN_PACKAGES < <(read_package_file "$PACMAN_PACKAGES_FILE")
  mapfile -t AUR_PACKAGES < <(read_package_file "$AUR_PACKAGES_FILE")
}

require_pacman() {
  if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman not found; skipping package installation."
    exit 0
  fi
}

set_sudo_command() {
  if [ "$(id -u)" -eq 0 ]; then
    return
  fi

  if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo is required to install packages with pacman." >&2
    exit 1
  fi

  SUDO_CMD=(sudo)
}

install_with_pacman() {
  if [ "$#" -eq 0 ]; then
    return
  fi

  "${SUDO_CMD[@]}" pacman -S "${PACMAN_ARGS[@]}" "$@"
}

install_pacman_packages() {
  if [ "${#PACMAN_PACKAGES[@]}" -eq 0 ]; then
    return
  fi

  install_with_pacman "${PACMAN_PACKAGES[@]}"
}

ensure_paru() {
  local build_root
  local paru_dir

  if [ "${#AUR_PACKAGES[@]}" -eq 0 ] || command -v paru >/dev/null 2>&1; then
    return
  fi

  if [ "$(id -u)" -eq 0 ]; then
    echo "AUR packages require running this script as a regular user so paru can be built." >&2
    exit 1
  fi

  install_with_pacman "${PACMAN_BOOTSTRAP_PACKAGES[@]}"

  build_root="$(mktemp -d)"
  paru_dir="$build_root/paru"
  trap 'rm -rf "$build_root"' RETURN

  echo "==> Cloning paru from $PARU_REPO_URL"
  git clone --depth 1 "$PARU_REPO_URL" "$paru_dir"

  if [ -f "$paru_dir/PKGBUILD" ]; then
    echo "==> Building paru with makepkg"
    (
      cd "$paru_dir"
      makepkg -si --needed "${PACMAN_ARGS[@]}"
    )
    return
  fi

  if [ -f "$paru_dir/Cargo.toml" ]; then
    echo "==> Building paru with cargo"
    install_with_pacman "${PARU_SOURCE_BOOTSTRAP_PACKAGES[@]}"
    (
      cd "$paru_dir"
      cargo build --release --locked
    )
    "${SUDO_CMD[@]}" install -Dm755 "$paru_dir/target/release/paru" /usr/local/bin/paru
    return
  fi

  echo "Unable to bootstrap paru from $PARU_REPO_URL: no PKGBUILD or Cargo.toml found." >&2
  exit 1
}

install_aur_packages() {
  if [ "${#AUR_PACKAGES[@]}" -eq 0 ]; then
    return
  fi

  if ! command -v paru >/dev/null 2>&1; then
    echo "::error::paru not found, but is required to install AUR packages."
    exit 1
  fi

  paru -S "${PARU_ARGS[@]}" "${AUR_PACKAGES[@]}"
}

parse_args "$@"
require_pacman
set_sudo_command
load_package_lists
install_with_pacman "${PACMAN_BOOTSTRAP_PACKAGES[@]}"
install_pacman_packages
ensure_paru
install_aur_packages
