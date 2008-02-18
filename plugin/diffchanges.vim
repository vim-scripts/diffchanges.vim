" Shows the changes made to the current buffer in a diff format.
" Last Modified: Mon 2008-02-18 04:03:51 (-0500)
" Maintainer:    Jeremy Cantrell <jmcantrell@gmail.com>

if exists("loaded_diffchanges")
	finish
endif

let loaded_diffchanges = 1

let g:diffchanges = []

command -bar DiffChanges :call DiffChanges()
nmap <silent> <leader>dc :DiffChanges<cr>

function DiffChanges() "{{{
	if len(expand('%')) == 0
		return
	endif
	if len(DiffChangesPair(bufnr('%'))) == 2
		call DiffChangesOff()
	else
		call DiffChangesOn()
	endif
endfunction "}}}
function DiffChangesOn() "{{{
	let filename = expand('%')
	let diffname = tempname()
	try
		call writefile(readfile(filename, 'b'), diffname, 'b')
		let b:diffchanges_savefdm = &fdm
		diffthis
		let buforig = bufnr('%')
		vsplit
		execute 'edit '.diffname
		diffthis
		let bufdiff = bufnr('%')
		call add(g:diffchanges, [buforig, bufdiff])
	endtry
endfunction "}}}
function DiffChangesOff() "{{{
	let pair = DiffChangesPair(bufnr('%'))
	execute 'bdelete! '.pair[1]
	execute 'buffer '.pair[0]
	diffoff
	let &fdm=b:diffchanges_savefdm
	call remove(g:diffchanges, index(g:diffchanges, pair))
endfunction "}}}
function DiffChangesPair(buf_num) "{{{
	for pair in g:diffchanges
		if count(pair, a:buf_num) > 0
			return pair
		endif
	endfor
endfunction "}}}
