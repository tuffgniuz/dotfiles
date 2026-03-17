# Mako Configuration

This directory contains a themeable `mako` notification setup.

## Files

- `config`: entry point loaded by `mako`
- `base.conf`: shared layout and behavior
- `themes/*.conf`: color themes

## Available Themes

- `gruvbox.conf`
- `nord.conf`
- `catppuccin-mocha.conf`
- `everforest-light.conf`

## Switch Themes

Edit `config` and change the second `include=` line to the theme you want:

```ini
include=~/.config/mako/base.conf
include=~/.config/mako/themes/nord.conf
```

Then reload `mako`:

```bash
makoctl reload
```

## Test Notifications

Normal:

```bash
notify-send 'Mako Test' 'Normal priority notification'
```

Low urgency:

```bash
notify-send -u low 'Mako Low Test' 'Low urgency styling'
```

Critical:

```bash
notify-send -u critical 'Mako Critical Test' 'Critical notifications persist until dismissed'
```

App-specific rule:

```bash
notify-send -a Spotify 'Now Playing' 'Artist - Track'
```

Grouped notifications:

```bash
notify-send -a Firefox 'Downloads' 'First grouped notification'
notify-send -a Firefox 'Downloads' 'Second grouped notification'
```

Replace an existing notification:

```bash
id=$(notify-send -p 'Replace Test' 'Version 1')
notify-send -r "$id" 'Replace Test' 'Version 2'
```
