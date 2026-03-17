function ytd --wraps='yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0' --description 'alias ytd=yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0'
    yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 $argv
end
