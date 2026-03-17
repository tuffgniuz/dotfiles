if status is-interactive
    # Commands to run in interactive sessions can go here
end

nitch

set -g fish_greeting

set -Ux SUDO_EDITOR nvim

if test -f ~/.config/fish/env.local.fish
    source ~/.config/fish/env.local.fish
end

# Gruvbox Material Fish Colors
set -g fish_color_normal d4be98
set -g fish_color_command a9b665
set -g fish_color_quote d8a657
set -g fish_color_redirection 7b5d44
set -g fish_color_end 89b482
set -g fish_color_error ea6962
set -g fish_color_param d4be98
set -g fish_color_comment 828a8a
set -g fish_color_match 7caea3
set -g fish_color_selection 3c3836
set -g fish_color_search_match --background=3c3836
set -g fish_color_history_current --bold
set -g fish_color_operator e78a4e
set -g fish_color_escape ea6962
set -g fish_color_cwd d8a657
set -g fish_color_cwd_root ea6962
set -g fish_color_valid_path --underline
set -g fish_color_autosuggestion 928374
set -g fish_color_user a9b665
set -g fish_color_host d4be98
set -g fish_color_cancel -r
set -g fish_pager_color_completion d4be98
set -g fish_pager_color_description 928374
set -g fish_pager_color_prefix 7caea3 --bold
set -g fish_pager_color_progress d4be98 --background=32302f

fish_add_path /home/tuffgniuz/.spicetify
fish_add_path /home/tuffgniuz/.local/bin
