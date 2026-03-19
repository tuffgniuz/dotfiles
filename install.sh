#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
PACMAN_PACKAGES_FILE="$DOTFILES_DIR/packages/pacman.txt"
AUR_PACKAGES_FILE="$DOTFILES_DIR/packages/aur.txt"
PARU_REPO_URL="${PARU_REPO_URL:-https://github.com/Morganamilo/paru.git}"
PACMAN_BOOTSTRAP_PACKAGES=(base-devel git)
PARU_SOURCE_BOOTSTRAP_PACKAGES=(rust)
SKIP_CLONES="${SKIP_CLONES:-0}"
SKIP_HELPERS="${SKIP_HELPERS:-0}"
SKIP_PACKAGES="${SKIP_PACKAGES:-0}"
MANAGED_COPY_MARKER=".dotfiles-install-managed"
TRACKED_CONFIG_PATHS=(
  fish
  ghostty
  gtk-3.0
  gtk-4.0
  kitty
  mako
  rofi
  tmux
  wofi
  yazi
  zathura
)
COPIED_DATA_PATHS=(
  themes
)
EXTERNAL_REPOS=(
  "https://github.com/tuffgniuz/hyprland.git|$CONFIG_DIR/hypr"
  "https://github.com/tuffgniuz/waybar.git|$CONFIG_DIR/waybar"
  "https://github.com/tuffgniuz/nvim.lua.git|$CONFIG_DIR/nvim"
)
HELPER_SCRIPTS=(
  "$CONFIG_DIR/hypr/scripts/install-hypr-theme-command.sh"
  "$CONFIG_DIR/hypr/scripts/install-desktop-theme-command.sh"
  "$CONFIG_DIR/waybar/scripts/install-waybar-theme-command.sh"
)
SUDO_CMD=()
PACMAN_ARGS=(--needed)
PARU_ARGS=(--needed)
PACMAN_PACKAGES=()
AUR_PACKAGES=()

log_section() {
  printf '\n==> %s\n' "$1"
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -y|--noconfirm)
        PACMAN_ARGS+=(--noconfirm)
        PARU_ARGS+=(--noconfirm)
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

have_pacman() {
  command -v pacman >/dev/null 2>&1
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
  trap '[[ -n "${build_root:-}" ]] && rm -rf -- "${build_root}"' RETURN

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

clone_or_update_repo() {
  local repo_url="$1"
  local target_dir="$2"

  if [ -d "$target_dir/.git" ]; then
    echo "==> Updating $(basename "$target_dir")"
    git -C "$target_dir" pull --ff-only
    return
  fi

  if [ -e "$target_dir" ] && [ ! -L "$target_dir" ]; then
    echo "Refusing to manage $target_dir because it exists and is not a git checkout." >&2
    return 1
  fi

  echo "==> Cloning $(basename "$target_dir")"
  git clone "$repo_url" "$target_dir"
}

clear_path_if_managed() {
  local source_path="$1"
  local target_path="$2"
  local backup_path=

  if [ -L "$target_path" ]; then
    local current_target
    current_target="$(readlink -f "$target_path")"
    if [ "$current_target" = "$source_path" ]; then
      echo "==> Removing legacy $target_path"
      rm "$target_path"
      return
    fi
  fi

  if [ -e "$target_path" ]; then
    backup_path="${target_path}.backup.$(date +%Y%m%d%H%M%S)"
    echo "==> Backing up existing $target_path to $backup_path"
    mv "$target_path" "$backup_path"
  fi
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

copy_data_path() {
  local rel_path="$1"
  local source_path="$DOTFILES_DIR/config/$rel_path"
  local target_path="$DATA_DIR/$rel_path"
  local legacy_config_path="$CONFIG_DIR/$rel_path"
  local backup_path=
  local entry=

  if [ ! -d "$source_path" ]; then
    echo "Skipping $source_path because it does not exist."
    return
  fi

  clear_path_if_managed "$source_path" "$legacy_config_path"
  mkdir -p "$(dirname "$target_path")"

  if [ -d "$target_path" ] && [ -f "$target_path/$MANAGED_COPY_MARKER" ]; then
    echo "==> Refreshing managed $target_path"
    rm -rf -- "$target_path"
  elif [ -e "$target_path" ] || [ -L "$target_path" ]; then
    backup_path="${target_path}.backup.$(date +%Y%m%d%H%M%S)"
    echo "==> Backing up existing $target_path to $backup_path"
    mv "$target_path" "$backup_path"
  fi

  echo "==> Copying $target_path"
  mkdir -p "$target_path"

  shopt -s dotglob nullglob
  for entry in "$source_path"/*; do
    if [ "$(basename "$entry")" = ".gitkeep" ]; then
      continue
    fi
    cp -a "$entry" "$target_path/"
  done
  shopt -u dotglob nullglob

  : > "$target_path/$MANAGED_COPY_MARKER"
}

install_helper_if_present() {
  local script_path="$1"

  if [ ! -e "$script_path" ]; then
    echo "Missing helper script: $script_path" >&2
    return 1
  fi

  if [ ! -x "$script_path" ]; then
    echo "Helper script is not executable: $script_path" >&2
    return 1
  fi

  echo "==> Running $(basename "$script_path")"
  "$script_path"
}

install_packages_if_needed() {
  if [ "$SKIP_PACKAGES" = "1" ]; then
    echo "==> Skipping package installation"
    return
  fi

  if ! have_pacman; then
    echo "==> pacman not found; skipping package installation"
    return
  fi

  echo "==> Installing packages"
  set_sudo_command
  load_package_lists
  install_with_pacman "${PACMAN_BOOTSTRAP_PACKAGES[@]}"
  install_pacman_packages
  ensure_paru
  install_aur_packages
}

parse_args "$@"
install_packages_if_needed

if [ "$SKIP_CLONES" != "1" ]; then
  repo_failures=0
  repo_spec=
  repo_url=
  target_dir=

  log_section "Cloning or updating external config repos"
  for repo_spec in "${EXTERNAL_REPOS[@]}"; do
    IFS='|' read -r repo_url target_dir <<< "$repo_spec"
    if ! clone_or_update_repo "$repo_url" "$target_dir"; then
      repo_failures=1
    fi
  done

  if [ "$repo_failures" -ne 0 ]; then
    echo "Aborting because one or more external config repos could not be managed." >&2
    exit 1
  fi
else
  echo "==> Skipping external repo clones"
fi

log_section "Linking tracked config"
for rel_path in "${TRACKED_CONFIG_PATHS[@]}"; do
  link_config_path "$rel_path"
done

log_section "Installing themes"
for rel_path in "${COPIED_DATA_PATHS[@]}"; do
  copy_data_path "$rel_path"
done

if [ "$SKIP_HELPERS" != "1" ]; then
  helper_failures=0
  helper_script=

  log_section "Installing helper commands"
  for helper_script in "${HELPER_SCRIPTS[@]}"; do
    if ! install_helper_if_present "$helper_script"; then
      helper_failures=1
    fi
  done

  if [ "$helper_failures" -ne 0 ]; then
    echo "Aborting because one or more helper installers are unavailable." >&2
    exit 1
  fi
else
  echo "==> Skipping helper installers"
fi

echo "==> Bootstrap complete"
