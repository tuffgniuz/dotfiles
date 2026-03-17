#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

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

clone_or_update_repo "https://github.com/tuffgniuz/hyprland.git" "$CONFIG_DIR/hypr"
clone_or_update_repo "https://github.com/tuffgniuz/waybar.git" "$CONFIG_DIR/waybar"
clone_or_update_repo "https://github.com/tuffgniuz/nvim.lua.git" "$CONFIG_DIR/nvim"

link_config_path "fish"
link_config_path "ghostty"
link_config_path "kitty"
link_config_path "mako"
link_config_path "rofi"
link_config_path "themes"
link_config_path "wofi"
link_config_path "yazi"
link_config_path "zathura"

install_helper_if_present "$CONFIG_DIR/hypr/scripts/install-hypr-theme-command.sh"
install_helper_if_present "$CONFIG_DIR/hypr/scripts/install-desktop-theme-command.sh"
install_helper_if_present "$CONFIG_DIR/waybar/scripts/install-waybar-theme-command.sh"

echo "==> Bootstrap complete"
