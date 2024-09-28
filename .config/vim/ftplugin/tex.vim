vim9script

def CompileAndRun()
    w
    silent !pdflatex %:p
    redraw!
    silent !zathura '%:p:r'.pdf & disown
enddef

nnoremap <buffer> <localleader>c <ScriptCmd>CompileAndRun()<LF>

nnoremap <buffer> <localleader>s :so /home/ezooz/.config/vim/ftplugin/tex.vim<LF>
