vim9script

def Run_Java()
    wa! | set makeprg=javac\ %
    silent make | wincmd l
    vert term java %:r | silent !rm %:r
    set autoread | redraw! | cwindow
enddef

def Past_Tests()
    wincmd w | :%d | set autoread | set autowrite
    silent !xclip -o clipboard > input.txt
    redraw! | wincmd h
enddef

nnoremap <buffer> <C-s> :vs input.txt <bar> wincmd h <bar> vertical resize 130 <LF>
nnoremap <buffer> <localleader>c <ScriptCmd>Run_Java()<LF>
nnoremap <buffer> <localleader>s <ScriptCmd>Past_Tests()<LF>
