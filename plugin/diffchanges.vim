" Filename:      diffchanges.vim
" Description:   Shows the changes made to the current buffer in a diff format
" Maintainer:    Jeremy Cantrell <jmcantrell@gmail.com>
" Last Modified: Sat 2008-02-23 03:58:24 (-0500)

if exists("loaded_diffchanges")
	finish
endif

let loaded_diffchanges = 1

let g:diffchanges = []

let s:save_cpo = &cpo
set cpo&vim

if !hasmapto('<Plug>DiffChangesToggle')
	nmap <silent> <unique> <leader>dc <Plug>DiffChangesToggle
endif

nnoremap <unique> <script> <Plug>DiffChangesToggle <SID>DiffChangesToggle
nnoremap <SID>DiffChangesToggle :DiffChangesToggle<cr>
command -bar DiffChangesToggle :call DiffChangesToggle()

function DiffChangesToggle() "{{{1
	if len(expand('%')) == 0
		return
	endif
	if len(DiffChangesPair(bufnr('%'))) == 2
		call DiffChangesOff()
	else
		call DiffChangesOn()
	endif
endfunction

function DiffChangesOn() "{{{1
	let filename = expand('%')
	let diffname = tempname()
	call writefile(readfile(filename, 'b'), diffname, 'b')
	let b:diffchanges_savefdm = &fdm
	diffthis
	let buforig = bufnr('%')
	vsplit
	execute 'edit '.diffname
	diffthis
	let bufdiff = bufnr('%')
	call add(g:diffchanges, [buforig, bufdiff])
endfunction

function DiffChangesOff() "{{{1
	let pair = DiffChangesPair(bufnr('%'))
	execute 'bdelete! '.pair[1]
	execute bufwinnr(pair[0]).'wincmd w'
	diffoff
	let &fdm=b:diffchanges_savefdm
	call remove(g:diffchanges, index(g:diffchanges, pair))
endfunction

function DiffChangesPair(buf_num) "{{{1
	for pair in g:diffchanges
		if count(pair, a:buf_num) > 0
			return pair
		endif
	endfor
endfunction

let &cpo = s:save_cpo
