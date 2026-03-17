function wgdown --wraps='sudo wg-quick down wg0' --description 'alias wgdown=sudo wg-quick down wg0'
    sudo wg-quick down wg0 $argv
end
