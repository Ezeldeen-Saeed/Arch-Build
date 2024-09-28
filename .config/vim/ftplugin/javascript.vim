vim9script

def Run_NodeJS()
    wa!

    below terminal node %:p 

    set autoread
    redraw!
    cwindow
enddef

nnoremap <buffer> <localleader>c <ScriptCmd>Run_NodeJS()<LF>
