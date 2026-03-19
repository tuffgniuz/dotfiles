# Dotfiles

This repository is the bootstrap layer for a small curated set of local config to setup my system.

It keeps these `~/.config` entries:

- `fish`
- `ghostty`
- `gtk-3.0`
- `gtk-4.0`
- `kitty`
- `mako`
- `rofi`
- `tmux`
- `wofi`
- `yazi`
- `zathura`

It also copies:

- `config/themes` to `~/.local/share/themes`

It also bootstraps these standalone repos into `~/.config`:

- `hypr`
- `waybar`
- `nvim`

## Fresh install

```bash
git clone <your-dotfiles-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` is the single entrypoint. It installs the package lists first,
bootstraps `paru` from `https://github.com/Morganamilo/paru`, then links the
tracked config and runs the helper installers.

## CI and testing

The installer supports CI-safe setup tests:

```bash
SKIP_CLONES=1 SKIP_HELPERS=1 XDG_CONFIG_HOME="$(mktemp -d)" XDG_DATA_HOME="$(mktemp -d)" ./install.sh --noconfirm
```

These flags skip external repo clones and helper-script execution, which makes it
safe to test the package bootstrap, theme copy, and symlink behavior in GitHub Actions.

## Existing machine

Run the installer again whenever you want to relink the tracked config set,
clone or update `hypr`, `waybar`, and `nvim`, or reinstall the helper commands
exposed by the Hyprland and Waybar repos.

Sensitive local files stay out of git. For example, Fish secrets live in
`~/.config/fish/env.local.fish`, which is loaded by the tracked
`config.fish` but ignored by this repo.

## Layout

```text
dotfiles/
  config/
    fish/
    ghostty/
    kitty/
    mako/
    rofi/
    themes/
    wofi/
    yazi/
    zathura/
  packages/
    pacman.txt
    aur.txt
  install.sh
```
