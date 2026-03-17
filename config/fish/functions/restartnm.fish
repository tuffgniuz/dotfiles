function restartnm --wraps='sudo systemctl restart NetworkManager' --description 'alias restartnm=sudo systemctl restart NetworkManager'
    sudo systemctl restart NetworkManager $argv
end
