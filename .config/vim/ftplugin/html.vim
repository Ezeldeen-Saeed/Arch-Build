vim9script

def StartLiveServer()
    if system('pgrep -x "live-server"') == ''
        call system('live-server --watch=*.html,*.css,*.js --quiet > /dev/null 2>&1 &')
        redraw!
        echo 'Live Server started.'
    else
        echo 'Live Server is already running.'
    endif
enddef

def StopLiveServer()
    call system('pkill -x "live-server"')
    redraw!
    echo 'Live Server stopped.'
enddef

nnoremap <buffer> <localleader>c <ScriptCmd> StartLiveServer()<CR>
nnoremap <buffer> <localleader>x <ScriptCmd> StopLiveServer()<CR>
