# Rozejin Color Specification

This document defines the color palette used by `rozejin`, making it easier to implement the theme across different tools and platforms (such as terminals, editors, or other UI components).

## Core Palette

The `rozejin` colorscheme revolves around a muted, rose-tinted dark background and soft, pastel-like syntax colors.

### Base Colors

| Name           | Hex       | Description                                      |
| -------------- | --------- | ------------------------------------------------ |
| `bg`           | `#1d2021` | Main background color                            |
| `bg_soft`      | `#222526` | Slightly lighter background                      |
| `bg_statusline`| `#181b1c` | Darker background, useful for status/tab lines   |
| `bg_float`     | `#202324` | Floating windows background                      |
| `bg_popup`     | `#242728` | Popups and menus background                      |
| `bg_cursorline`| `#252829` | Cursorline or active row background              |
| `bg_visual`    | `#43313a` | Visual selection background                      |
| `bg_search`    | `#4a3841` | Search highlight background                      |
| `bg_reference` | `#353039` | Borders or reference highlights                  |
| `fg`           | `#eadfe2` | Primary foreground (text)                        |
| `fg_soft`      | `#c8b7bb` | Secondary foreground, less contrast              |
| `fg_faint`     | `#a08c91` | Comments and faint text                          |
| `fg_nc`        | `#7d6f73` | Non-current text (inactive window text/borders)  |

### Syntax & Accent Colors

| Name           | Hex       | Description                                      |
| -------------- | --------- | ------------------------------------------------ |
| `rose`         | `#ff9fc0` | Primary accent color (keywords, active elements) |
| `rose_soft`    | `#e7b9c9` | Muted accent color                               |
| `red`          | `#de6f8f` | Errors, deletions, some syntax elements          |
| `orange`       | `#d8a07b` | Warnings, escapes, numbers                       |
| `yellow`       | `#e5d1a6` | Strings, directories                             |
| `green`        | `#bfd2c0` | Additions, successful operations, strings        |
| `aqua`         | `#aac3cf` | Functions, attributes, URLs                      |
| `blue`         | `#b7c5de` | Operators, match highlights                      |
| `purple`       | `#c9b3d9` | Constants, types                                 |

### Diagnostic & Diff Backgrounds

These are low-contrast tints used for background highlights in code editors (e.g., Git diffs or LSP diagnostics).

| Name             | Hex       | Description                |
| ---------------- | --------- | -------------------------- |
| `bg_diff_add`    | `#243126` | Added lines                |
| `bg_diff_change` | `#2a2e36` | Changed lines              |
| `bg_diff_delete` | `#3a2628` | Deleted lines              |
| `bg_error`       | `#42262d` | Error diagnostic line bg   |
| `bg_warn`        | `#473626` | Warning diagnostic line bg |
| `bg_info`        | `#24333a` | Info diagnostic line bg    |
| `bg_hint`        | `#25322d` | Hint diagnostic line bg    |

---

## Terminal ANSI 16-Color Palette

For terminal emulators (like Kitty, Ghostty, Alacritty), here is the standard 16-color ANSI mapping derived from the core palette:

### Standard Colors (0-7)

| ANSI Color | Name          | Hex       |
| ---------- | ------------- | --------- |
| **0**      | Black         | `#1d2021` |
| **1**      | Red           | `#de6f8f` |
| **2**      | Green         | `#bfd2c0` |
| **3**      | Yellow        | `#d8c299` |
| **4**      | Blue          | `#b7c5de` |
| **5**      | Magenta       | `#c9b3d9` |
| **6**      | Cyan          | `#aac3cf` |
| **7**      | White         | `#c8b7bb` |

### Bright Colors (8-15)

| ANSI Color | Name          | Hex       |
| ---------- | ------------- | --------- |
| **8**      | Bright Black  | `#433b3e` |
| **9**      | Bright Red    | `#ff9fc0` |
| **10**     | Bright Green  | `#d6e5d6` |
| **11**     | Bright Yellow | `#e5d1a6` |
| **12**     | Bright Blue   | `#c9d5ea` |
| **13**     | Bright Magenta| `#e7b9c9` |
| **14**     | Bright Cyan   | `#c1d6df` |
| **15**     | Bright White  | `#eadfe2` |

### UI Colors (Terminal Settings)

| Element                  | Value     |
| ------------------------ | --------- |
| Background               | `#1d2021` |
| Foreground               | `#eadfe2` |
| Cursor Color             | `#ff9fc0` |
| Cursor Text              | `#1d2021` |
| Selection Background     | `#43313a` |
| Selection Foreground     | `#eadfe2` |
| URL / Links              | `#aac3cf` |
| Active Border            | `#ff9fc0` |
| Inactive Border          | `#353039` |

---

## Porting Guidelines

When porting `rozejin` to a new environment, keep the following principles in mind:

1. **Overall Tone**: The theme should feel like a soft dark theme, subtly tinted towards a muted rose (`#1d2021`).
2. **Accents**: Use the bright rose (`#ff9fc0`) sparingly for primary active states, cursor, or crucial keywords to draw attention.
3. **Selection**: Highlight selections with the distinct deep rose-purple (`#43313a`) to keep them visible but not overwhelming.
4. **Borders**: For structural elements (panels, inactive tabs, borders), use `#353039` or `#181b1c` to create depth without stark contrast.
