# Personal Arch Setup

This repo is the setup I use for my own Arch machine.

It is not meant to be a polished, universal dotfiles starter for everyone. It
exists so I can get back to a familiar system quickly on a fresh install,
restore the config I actually use, and pull in the companion repos that make up
the rest of my desktop.

If you want to borrow ideas or try parts of it, feel free. Just expect a setup
that is opinionated, Arch-specific, and shaped around how I like my system to
work.

## What this repo manages

Tracked and linked into `~/.config`:

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

Copied into `~/.local/share`:

- `themes`

Cloned or updated as companion repos in `~/.config`:

- `hypr` from `https://github.com/tuffgniuz/hyprland.git`
- `waybar` from `https://github.com/tuffgniuz/waybar.git`
- `nvim` from `https://github.com/tuffgniuz/nvim.lua.git`

## Fresh install

```bash
git clone https://github.com/tuffgniuz/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` is the entrypoint. It installs packages from `packages/`,
bootstraps `paru` when needed, links the tracked config, copies themes, and
runs helper installers exposed by the Hyprland and Waybar repos.

## Re-running on an existing machine

Run the installer again any time I want to:

- relink the tracked config
- sync `hypr`, `waybar`, and `nvim`
- reinstall helper commands from those repos

Sensitive local files stay outside git. For example,
`~/.config/fish/env.local.fish` is loaded by the tracked Fish config but is not
committed here.

## CI and testing

The installer supports a CI-safe test mode:

```bash
SKIP_CLONES=1 SKIP_HELPERS=1 XDG_CONFIG_HOME="$(mktemp -d)" XDG_DATA_HOME="$(mktemp -d)" ./install.sh --noconfirm
```

That skips external repo clones and helper scripts, which makes it safe to test
package bootstrap, theme copy, and symlink behavior in automation.

## About the name

`dotfiles` is close enough, but it is probably not the most precise name
anymore.

This repo does include dotfiles, but it also installs packages, copies themes,
and bootstraps the rest of my desktop from separate repos. It is closer to a
personal Arch bootstrap or workstation setup than a plain dotfiles repo.

If I ever rename it, something like `arch-setup`, `arch-bootstrap`, or
`workstation-setup` would describe it better.

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
