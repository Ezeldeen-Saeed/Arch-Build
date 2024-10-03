vim9script

def Run_CPP()
    wa! | set makeprg=g++\ % | silent make | wincmd l
    vert term ./a.out | silent !rm a.out
    set autoread | redraw! | cwindow
enddef

def Past_Tests()
    wincmd w | :%d | set autoread | set autowrite
    silent !xclip -o clipboard > input.txt | redraw! | wincmd h
enddef

nnoremap <buffer> <C-s> :vs input.txt <bar> wincmd h <LF>
nnoremap <buffer> <localleader>c <ScriptCmd>Run_CPP()<LF>
nnoremap <buffer> <localleader>s <ScriptCmd>Past_Tests()<LF>
