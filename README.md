# Dotfiles

This repository is the bootstrap layer for a small curated set of local config.

It keeps these `~/.config` entries:

- `fish`
- `ghostty`
- `kitty`
- `mako`
- `rofi`
- `themes`
- `wofi`
- `yazi`
- `zathura`

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

If you want package installation too:

```bash
./scripts/install-packages.sh
```

That script uses `pacman` for official packages and `paru` for AUR packages when available.

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
  scripts/
    install-packages.sh
  install.sh
```
