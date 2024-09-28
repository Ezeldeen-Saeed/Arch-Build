vim9script

def Run_Java()
    wa!  " Save all buffers
    set makeprg=javac\ %
    silent make
    wincmd l

    below terminal java %:r
    silent !rm %:r
    set autoread
    redraw!
    cwindow
enddef

# Copy test case and paste into input.txt with Ctrl + T

def Past_Tests()
    wincmd w
    #startinsert
    :%d
    set autoread
    set autowrite
    # For native Linux
#    silent !xclip -o clipboard > input.txt
    # For WSL
    silent !powershell.exe Get-Clipboard > input.txt
    redraw!
    wincmd h
enddef

nnoremap <buffer> <C-s> :vs input.txt <bar> :wincmd h <bar> :vertical resize 130 <LF>

nnoremap <buffer> <localleader>c <ScriptCmd>Run_Java()<LF>
nnoremap <buffer> <localleader>s <ScriptCmd>Past_Tests()<LF>
