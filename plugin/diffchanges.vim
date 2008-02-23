" Filename:      diffchanges.vim
" Description:   Shows the changes made to the current buffer in a diff format
" Maintainer:    Jeremy Cantrell <jmcantrell@gmail.com>
" Last Modified: Sun 2008-02-24 02:08:09 (-0500)

if exists("loaded_diffchanges")
	finish
endif

let loaded_diffchanges = 1

let g:diffchanges_diff = []
let g:diffchanges_patch = []
let g:diffchanges_modes = ['diff', 'patch']

let s:save_cpo = &cpo
set cpo&vim

if !hasmapto('<Plug>DiffChangesDiffToggle')
	nmap <silent> <unique> <leader>dcd <Plug>DiffChangesDiffToggle
endif

if !hasmapto('<Plug>DiffChangesPatchToggle')
	nmap <silent> <unique> <leader>dcp <Plug>DiffChangesPatchToggle
endif

nnoremap <unique> <script> <Plug>DiffChangesDiffToggle <SID>DiffChangesDiffToggle
nnoremap <unique> <script> <Plug>DiffChangesPatchToggle <SID>DiffChangesPatchToggle
nnoremap <SID>DiffChangesDiffToggle :DiffChangesDiffToggle<cr>
nnoremap <SID>DiffChangesPatchToggle :DiffChangesPatchToggle<cr>
command -bar DiffChangesDiffToggle :call s:DiffChangesToggle('diff')
command -bar DiffChangesPatchToggle :call s:DiffChangesToggle('patch')

function s:DiffChangesToggle(mode) "{{{1
	if count(g:diffchanges_modes, a:mode) == 0
		return
	endif
	if len(expand('%')) == 0
		return
	endif
	let [dcm, pair] = s:DiffChangesPair(bufnr('%'))
	if count(g:diffchanges_modes, dcm) == 0
		call s:DiffChangesOn(a:mode)
	else
		call s:DiffChangesOff()
	endif
endfunction

function s:DiffChangesOn(mode) "{{{1
	if count(g:diffchanges_modes, a:mode) == 0
		return
	endif
	let filename = expand('%')
	let diffname = tempname()
	let buforig = bufnr('%')
	if a:mode == 'diff'
		call writefile(readfile(filename, 'b'), diffname, 'b')
		let b:diffchanges_savefdm = &fdm
		let save_ft=&ft
		diffthis
		vsplit
		execute 'edit '.diffname
		let &ft=save_ft
		diffthis
		let bufdiff = bufnr('%')
	elseif a:mode == 'patch'
		execute 'w! '.diffname
		execute 'split '.filename.'.patch'
		normal ggdG
		setlocal filetype=diff
		setlocal foldmethod=manual
		execute 'silent -r! diff -u '.filename.' '.diffname
	endif
	autocmd BufWinLeave <buffer> call s:DiffChangesOff()
	let bufdiff = bufnr('%')
	call add(eval('g:diffchanges_'.a:mode), [buforig, bufdiff])
endfunction

function s:DiffChangesOff() "{{{1
	let [dcm, pair] = s:DiffChangesPair(bufnr('%'))
	execute 'bdelete! '.pair[1]
	execute bufwinnr(pair[0]).'wincmd w'
	if dcm == 'diff'
		diffoff
		let &fdm=b:diffchanges_savefdm
	endif
	let dcp = eval('g:diffchanges_'.dcm)
	call remove(dcp, index(dcp, pair))
endfunction

function s:DiffChangesPair(buf_num) "{{{1
	for dcm in g:diffchanges_modes
		let pairs = eval('g:diffchanges_'.dcm)
		for pair in pairs
			if count(pair, a:buf_num) > 0
				return [dcm, pair]
			endif
		endfor
	endfor
	return [0, 0]
endfunction

let &cpo = s:save_cpo
