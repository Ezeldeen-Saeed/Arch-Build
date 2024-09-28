vim9script

def Run_CPP()
    wa!
    set makeprg=g++\ %
    silent make
    wincmd l
   
    below terminal ./a.out
    silent !rm a.out
    set autoread
    redraw!
    cwindow
enddef

#copy your test case and just ctrl + t 
#will clear and paste in input.txt and return you to main.cpp

def Past_Tests()
    wincmd w
    #startinsert
    :%d
    set autoread
    set autowrite
    #for native Linux
#    silent !xclip -o clipboard > input.txt
    #for WSL
    silent !powershell.exe Get-Clipboard > input.txt
    redraw!
    wincmd h
enddef
nnoremap <buffer> <C-s> :vs input.txt <bar> :wincmd h <bar> :vertical resize 100 <LF>


nnoremap <buffer> <localleader>c <ScriptCmd>Run_CPP() <LF>
nnoremap <buffer> <localleader>s <ScriptCmd>Past_Tests()<LF>
#nnoremap <buffer> <C-w> :%y+<LF>
