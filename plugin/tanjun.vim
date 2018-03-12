" load tanjun
let g:loaded_tanjun = 1
" default value is enabled
let g:tanjun_enable = get(g:, 'tanjun_enable', 1)
" default value is enabled
let g:tanjun_switch_number = get(g:, 'tanjun_switch_number', 1)
" default value is enabled
let g:tanjun_switch_relative_number = get(g:, 'tanjun_switch_relative_number', 1)
" command for getting branch name
let s:git_branch_command = 'git rev-parse --abbrev-ref HEAD 2> /dev/null'

function! s:check_not_modified()
    let l:str = '⚫'

    if &mod
        let l:str = '◈ '
    endif

    return l:str
endfunction

function! s:build_default_str(color, left, right)
    let l:left = '%#' . a:color . '#█▌ ' . a:left
    let l:right = a:right . '%#' . a:color . '# ▐█'
    return l:left . '%=' . l:right
endfunction

function! s:get_git_branch()
    let l:git_branch_raw = system(s:git_branch_command)
    let l:git_branch = substitute(l:git_branch_raw, '\n', '', '')
    let l:git = ''

    if !empty(l:git_branch)
        let l:git = '  %#WinActiveGit# (' . l:git_branch . ') '
    endif

    return l:git
endfunction

function! s:set_all(val)
    if g:tanjun_switch_number
        if a:val
            set number
        else
            set nonumber
        endif
    endif

    if g:tanjun_switch_relative_number
        if a:val
            set relativenumber
        else
            set norelativenumber
        endif
    endif

    redraw
endfunction

function! BuildWinEnterString()
    let l:mod = s:check_not_modified()
    let l:git = s:get_git_branch()

    " Left side
    let l:txt_color = '%#WinActiveTxt#'
    let l:left = l:txt_color . l:mod . '%t ' . l:mod

    " Right side
    let l:right = '[%l|%L]::%-4v%3p%%' . l:git

    return s:build_default_str('WinActive', l:left, l:right)
endfunction

function! BuildWinLeaveString()
    let l:mod = s:check_not_modified()
    let l:left = l:mod . '%t ' . l:mod
    let l:right = strftime("%c")
    return s:build_default_str('WinInactive', l:left, l:right)
endfunction

function! TanjunWinEnter()
    call s:set_all(1)
    setlocal statusline=%!BuildWinEnterString()
    setlocal cursorline
endfunction

function! TanjunWinLeave()
    call s:set_all(0)
    setlocal statusline=%!BuildWinLeaveString()
    setlocal nocursorline
endfunction

function! tanjun#enable()
    let g:tanjun_enabled = 1

    let g:tanjun_color = {
                \'active': [ 255, 2 ],
                \'active_txt': [ 255, 232 ],
                \'active_git': [ 1, 255 ],
                \'inactive': [ 240, 232 ]
                \}

    autocmd WinEnter * call TanjunWinEnter()
    autocmd BufWinEnter * call TanjunWinEnter()
    autocmd WinLeave * call TanjunWinLeave()
    autocmd BufWinLeave * call TanjunWinLeave()

    let g:tanjun_def_highlights = get(g:, 'tanjun_def_highlights', 1)
    if g:tanjun_def_highlights
        execute('highlight WinActive cterm=None ctermbg=' . g:tanjun_color['active'][0]
                    \ . ' ctermfg=' . g:tanjun_color['active'][1])
        execute('highlight WinActiveTxt cterm=None ctermbg=' . g:tanjun_color['active_txt'][0]
                    \ . ' ctermfg=' . g:tanjun_color['active_txt'][1])
        execute('highlight WinActiveGit cterm=bold ctermbg=' . g:tanjun_color['active_git'][0]
                    \ . ' ctermfg=' . g:tanjun_color['active_git'][1])
        execute('highlight WinInactive cterm=None ctermbg=' . g:tanjun_color['inactive'][0]
                    \ . ' ctermfg=' . g:tanjun_color['inactive'][1])
    endif

    call TanjunWinEnter()
endfunction

" if tanjun is set to be enabled, enable it
if g:tanjun_enable
    call tanjun#enable()
endif
