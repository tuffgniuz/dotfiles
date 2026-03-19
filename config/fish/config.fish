if status is-interactive
    # Commands to run in interactive sessions can go here
end

nitch

set -g fish_greeting

set -Ux SUDO_EDITOR nvim

if test -f ~/.config/fish/env.local.fish
    source ~/.config/fish/env.local.fish
end

# rozejin Fish Colors
source ~/.config/fish/themes/rozejin.fish

fish_add_path /home/tuffgniuz/.spicetify
fish_add_path /home/tuffgniuz/.local/bin
