function wgup --wraps='sudo wg-quick up wg0' --description 'alias wgup=sudo wg-quick up wg0'
    sudo wg-quick up wg0 $argv
end
