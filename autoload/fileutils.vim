"{{{1 protector
if exists('s:loaded_plugin')
    finish
endif
let s:loaded_plugin=1
"{{{1 GetDirContents :: (path) -> [filenames]
function fileutils#GetDirContents(directory)
    if type(a:directory)!=type("") || !isdirectory(a:directory)
        return -1
    endif
    " fnamemodify adds trailing path separator when expanding with :p
    let fullpath=fnamemodify(a:directory, ':p')
    return s:GetDirContents(fnamemodify(a:directory, ':p')[:-2])
endfunction
if os#OS=~#'unix'
    function s:GetDirContents(directory)
        let dirlist=split(glob(a:directory.'/*'), "\n", 1)
        let r=[]
        for directory in dirlist
            if directory[0]!=#'/'
                let r[-1].="\n".directory
            else
                call add(r, directory)
            endif
        endfor
        return r
    endfunction
elseif os#OS=~#'win'
    function s:GetDirContents(directory)
        return split(glob(a:directory.'\\*'), "\n")
    endfunction
else
    let s:escapedPathSeparator=escape(os#pathSeparator, '`*[]\')
    function s:GetDirContents(directory)
        return split(glob(a:directory.
                    \s:escapedPathSeparator.'*'), "\n")
    endfunction
endif

" vim: ft=vim:fenc=utf-8:tw=80:ts=4:expandtab
