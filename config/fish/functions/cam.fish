function cam --wraps='mpv av://v4l2:/dev/video0' --description 'alias cam=mpv av://v4l2:/dev/video0'
    mpv av://v4l2:/dev/video0 $argv
end
