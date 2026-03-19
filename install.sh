#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
PACKAGES_SCRIPT="$DOTFILES_DIR/scripts/install-packages.sh"
SKIP_CLONES="${SKIP_CLONES:-0}"
SKIP_HELPERS="${SKIP_HELPERS:-0}"
SKIP_PACKAGES="${SKIP_PACKAGES:-0}"
PACKAGE_ARGS=()

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -y|--noconfirm)
        PACKAGE_ARGS+=("--noconfirm")
        ;;
      --skip-clones)
        SKIP_CLONES=1
        ;;
      --skip-helpers)
        SKIP_HELPERS=1
        ;;
      --skip-packages)
        SKIP_PACKAGES=1
        ;;
      -h|--help)
        cat <<'EOF'
Usage: ./install.sh [options]

Options:
  -y, --noconfirm    Pass --noconfirm to the package installer
  --skip-packages    Skip package installation
  --skip-clones      Skip external repo clones/updates
  --skip-helpers     Skip helper installer scripts
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

clone_or_update_repo() {
  local repo_url="$1"
  local target_dir="$2"

  if [ -d "$target_dir/.git" ]; then
    echo "==> Updating $(basename "$target_dir")"
    git -C "$target_dir" pull --ff-only
    return
  fi

  if [ -e "$target_dir" ] && [ ! -L "$target_dir" ]; then
    echo "Skipping $target_dir because it exists and is not a git checkout."
    return
  fi

  echo "==> Cloning $(basename "$target_dir")"
  git clone "$repo_url" "$target_dir"
}

link_config_path() {
  local rel_path="$1"
  local source_path="$DOTFILES_DIR/config/$rel_path"
  local target_path="$CONFIG_DIR/$rel_path"
  local backup_path=

  mkdir -p "$(dirname "$target_path")"

  if [ -L "$target_path" ]; then
    local current_target
    current_target="$(readlink -f "$target_path")"
    if [ "$current_target" = "$source_path" ]; then
      echo "==> $rel_path already linked"
      return
    fi
    rm "$target_path"
  elif [ -e "$target_path" ]; then
    backup_path="${target_path}.backup.$(date +%Y%m%d%H%M%S)"
    echo "==> Backing up existing $target_path to $backup_path"
    mv "$target_path" "$backup_path"
  fi

  echo "==> Linking $target_path"
  ln -s "$source_path" "$target_path"
}

install_helper_if_present() {
  local script_path="$1"

  if [ -x "$script_path" ]; then
    echo "==> Running $(basename "$script_path")"
    "$script_path"
  fi
}

install_packages_if_needed() {
  if [ "$SKIP_PACKAGES" = "1" ]; then
    return
  fi

  if [ ! -x "$PACKAGES_SCRIPT" ]; then
    echo "Skipping package install because $PACKAGES_SCRIPT is not executable."
    return
  fi

  echo "==> Installing packages"
  "$PACKAGES_SCRIPT" "${PACKAGE_ARGS[@]}"
}

parse_args "$@"
install_packages_if_needed

if [ "$SKIP_CLONES" != "1" ]; then
  clone_or_update_repo "https://github.com/tuffgniuz/hyprland.git" "$CONFIG_DIR/hypr"
  clone_or_update_repo "https://github.com/tuffgniuz/waybar.git" "$CONFIG_DIR/waybar"
  clone_or_update_repo "https://github.com/tuffgniuz/nvim.lua.git" "$CONFIG_DIR/nvim"
fi

link_config_path "fish"
link_config_path "ghostty"
link_config_path "gtk-3.0"
link_config_path "gtk-4.0"
link_config_path "kitty"
link_config_path "mako"
link_config_path "rofi"
link_config_path "themes"
link_config_path "tmux"
link_config_path "wofi"
link_config_path "yazi"
link_config_path "zathura"

if [ "$SKIP_HELPERS" != "1" ]; then
  install_helper_if_present "$CONFIG_DIR/hypr/scripts/install-hypr-theme-command.sh"
  install_helper_if_present "$CONFIG_DIR/hypr/scripts/install-desktop-theme-command.sh"
  install_helper_if_present "$CONFIG_DIR/waybar/scripts/install-waybar-theme-command.sh"
fi

echo "==> Bootstrap complete"
