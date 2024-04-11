augroup start_in_normal_mode
  autocmd!
  autocmd BufEnter * call feedkeys("\<Esc>")
augroup END

let mapleader="\<Space>"

" allow repeated indentation in visual mode
:vnoremap > >gv
:vnoremap < <gv

set ignorecase

if exists('g:vscode')
	nnoremap <Leader>0 <Cmd>call VSCodeNotify('git.openChange')<CR>
	xnoremap <Leader>0 <Cmd>call VSCodeNotify('git.openChange')<CR>
	nnoremap <Leader>9 <Cmd>call VSCodeNotify('git.openFile')<CR>
	xnoremap <Leader>9 <Cmd>call VSCodeNotify('git.openFile')<CR>

	nnoremap <Leader>ca <Cmd>call VSCodeNotify('editor.action.quickFix')<CR>
	xnoremap <Leader>ca <Cmd>call VSCodeNotify('editor.action.quickFix')<CR>
	
	nnoremap <Leader>a <Cmd>call VSCodeNotify('vscode-harpoon.addGlobalEditor')<CR>
	xnoremap <Leader>a <Cmd>call VSCodeNotify('vscode-harpoon.addGlobalEditor')<CR>
	nnoremap <Leader>e <Cmd>call VSCodeNotify('vscode-harpoon.editGlobalEditors')<CR>
	xnoremap <Leader>e <Cmd>call VSCodeNotify('vscode-harpoon.editGlobalEditors')<CR>
	nnoremap <Leader>pe <Cmd>call VSCodeNotify('vscode-harpoon.editorGlobalQuickPick')<CR>
	xnoremap <Leader>pe <Cmd>call VSCodeNotify('vscode-harpoon.editorGlobalQuickPick')<CR>

	for i in range(1, 8)
	    execute 'nnoremap <Leader>'.i.' <Cmd>call VSCodeNotify("vscode-harpoon.gotoGlobalEditor'.i.'")<CR>'
	    execute 'xnoremap <Leader>'.i.' <Cmd>call VSCodeNotify("vscode-harpoon.gotoGlobalEditor'.i.'")<CR>'
	endfor

	for i in range(1, 8)
	    execute 'nnoremap <Leader>a'.i.' <Cmd>call VSCodeNotify("vscode-harpoon.addGlobalEditor'.i.'")<CR>'
	    execute 'xnoremap <Leader>a'.i.' <Cmd>call VSCodeNotify("vscode-harpoon.addGlobalEditor'.i.'")<CR>'
	endfor

	nnoremap <Leader>b <Cmd>call VSCodeNotify('vscode-harpoon.gotoPreviousGlobalHarpoonEditor')<CR>
	xnoremap <Leader>b <Cmd>call VSCodeNotify('vscode-harpoon.gotoPreviousGlobalHarpoonEditor')<CR>
	nnoremap ? <Cmd>call VSCodeNotify('workbench.action.findInFiles', { 'query': expand('<cword>')})<CR>
	xnoremap ? :<C-U>call <SID>VSCodeSearch()<CR>

	function! s:VSCodeSearch()
	    normal! gv"zy
	    call VSCodeNotify('workbench.action.findInFiles', { 'query': @z })
	endfunction
	
 	" xmap <C-/> <Plug>VSCodeCommentarygv
    	" nmap <C-/> <Plug>VSCodeCommentaryLine

	xnoremap <C-/> <Cmd>call VSCodeNotify('editor.action.commentLine')<CR>
	nnoremap <C-/> <Cmd>call VSCodeNotify('editor.action.commentLine')<CR>

	xnoremap <leader>r xi[]<Esc>P
endif

set clipboard=unnamed
