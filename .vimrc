" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of the file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type. 
filetype indent on

" Turn syntax highlighting on.
syntax on

" Add numbers to each line on the left-hand side.
set number relativenumber

" Highlight cursor line underneath the cursor horizontally.
" set cursorline

" Highlight cursor line underneath the cursor vertically.
" set cursorcolumn

" Set shift width to 4 spaces.
set shiftwidth=4

" Set tab width to columns.
set tabstop=4
set softtabstop=4
set smartindent

" Use space characters instead of tabs.
set expandtab

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
set hlsearch

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" PLUGINS ---------------------------------------------------------------- {{{
" Plugin code goes here.

    call plug#begin('~/.vim/plugged')
        Plug 'preservim/nerdtree'
        Plug 'tpope/vim-surround'
        Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
        Plug 'junegunn/fzf.vim'
        Plug 'terryma/vim-smooth-scroll'
        Plug 'junegunn/vim-peekaboo'
    call plug#end()

" }}}


" MAPPINGS --------------------------------------------------------------- {{{

" Mappings code goes here.

    " tab management
    nnoremap <leader>h :tabp<CR>
    nnoremap <leader>l :tabn<CR>
    nnoremap <leader>tn :tabnew<CR>
    nnoremap <leader>tc :tabclose<CR>
    nnoremap <leader>to :tabonly<CR>

    " session management
    function! s:SessionName()
      return expand('~/.vim/sessions/') . substitute(getcwd(), '/', '_', 'g') . '.vim'
    endfunction

    nnoremap <leader>sw :call mkdir(expand('~/.vim/sessions/'), 'p') \| execute 'mksession! ' . <SID>SessionName()<CR>
    nnoremap <leader>ss :execute 'source ' . <SID>SessionName()<CR>

    " vim-smooth-scroll mapping
    " noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 25, 2)<CR>
    " noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 25, 2)<CR>
    " noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 25, 4)<CR>
    " noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 25, 4)<CR>
" }}}


" VIMSCRIPT -------------------------------------------------------------- {{{

" This will enable code folding.
" Use the marker method of folding.
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" Set indentation to 2 spaces for js,json,ts,html
autocmd Filetype html,js,json,jsx,ts,tsx setlocal tabstop=2 shiftwidth=2 expandtab

" If Vim version is equal to or greater than 7.3 enable undofile.
" This allows you to undo changes to a file even after saving it.
if version >= 703
    set undodir=~/.vim/backup
    set undofile
    set undoreload=10000
endif

" More Vimscripts code goes here.

" }}}


" STATUS LINE ------------------------------------------------------------ {{{

" Status bar code goes here.

" }}}
