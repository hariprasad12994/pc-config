"Set nocompatible to ward off unexpected things the distro might have made,
" as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto indenting for each filetype, and
" for plugind that are filetype specific
filetype indent plugin on

" Enable syntax highlighting
syntax on

" Disable audio bells
set noerrorbells

" Set hidden so that while switching between buffers and tabs vim does'nt 
" prompt to save or move with the override ! command
set hidden 

" Indentation settings for using 4 spaces instead of tabs
" Do not change 'tabstop' from its default value of 8 with this setup
set tabstop=4 
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab

" Enable smart indentation
set smartindent
set autoindent
set wrap
set textwidth=80
" In case of indentation failure binding a key for full file indentation
noremap <C-i> gg=G

"Display line numbers on the left
set number
" Toggle line numbers to hybrid numbering, ie relative numbering 
" with respect to the current line alone
noremap <F3> :set number<CR>:set relativenumber!<CR>

" Display the cursor position on the last line of the screen or in the 
" status line of a window
set ruler

" Set a toggle key for paste and nopaste. Useful in certain scnarios like 
" disabling autocommenting
set pastetoggle=<F11>

" Enable mouse for all modes
set mouse=a

" Disable arrow keys in normal mode
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
vnoremap <up> <nop>
vnoremap <down> <nop>
vnoremap <left> <nop>
vnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" Highlight matching braces
set showmatch

" Display the cursor position on the last line of the screen or in the line 
" status line of a window
set ruler

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Enable autocomplete menu for vim commands
set wildmenu

" Search setting
" Enable incremental search
" Enable highlighted search by default for all the session
" Disable highlight search option with binding <leader><space>
set incsearch
set hlsearch
nnoremap <leader><space> :nohlsearch<CR>

" Personal remapping.
" Swap j and k
nnoremap j k
nnoremap k j
vnoremap j k
vnoremap k j

" Enable pasting from external clipboard
set clipboard=unnamedplus

" Enable block folding in case of code blocks
set foldenable
" Set automatic folding once the nesting is greater than 20
set foldlevelstart=20
" todo : Key binding for fold-unfold toggling 
set foldmethod=syntax
" Turn backup off since most of the stuffs are part of version control
set noswapfile
set nobackup

" Enable persistent undo on so that you can undo even between close 
" and reopen operations
" todo check if this is really useful, and re-enable it
set undodir=~/.vim/undodir
set undofile

" Split below by default in case of a horizontal split
set splitbelow
" Split right by default in case of a vertical split
set splitright

set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=black

if has('gui_running')
    set guifont=Source\ Code\ Pro\ 10
endif

call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
" YCM is a plugin with a compiled component. If you update YCM using Vundle and
" the ycm_core library APIs have changed (happens rarely), YCM will notify you
" to recompile it. You should then rerun the install process.
Plug 'https://github.com/ycm-core/YouCompleteMe'
Plug 'https://github.com/rdnetto/YCM-Generator'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
Plug 'preservim/nerdcommenter'
Plug 'frazrepo/vim-rainbow'
Plug 'https://github.com/vim-scripts/taglist.vim'
Plug 'https://github.com/mileszs/ack.vim'
Plug 'junegunn/fzf', {'do': { -> fzf#install()}}
Plug 'junegunn/fzf.vim'
Plug 'https://github.com/weirongxu/plantuml-previewer.vim'
Plug 'https://github.com/tyru/open-browser.vim'
Plug 'https://github.com/aklt/plantuml-syntax'
Plug 'https://github.com/arcticicestudio/nord-vim'
Plug 'flazz/vim-colorschemes'
call plug#end()

colorscheme monokai-phoenix
set background=dark

" Toggle the nerdtree on hitting Ctrl+E
map <C-e> :NERDTreeToggle<CR>

" Configure vim rainbow balancer for c, cpp, rust
au Filetype c,cpp,rs call rainbow#load()
let g:rainbow_ctermfgs = ['lightblue', 'lightgreen', 'yellow', 'red', 'magenta']

let g:ycm_clangd_binary_path = "usr/bin/clangd"

" Macros
" Initiate a numbered list starting from 1.
let @a="^i1. \<Esc>k"
" Complete a numbered list until given number. Use in conjuction with @a. 
" For example use @a6@n to create a numbered list of 1 till 6
let @n="^i\<C-y>\<C-y>\<C-y>\<Esc>^\<C-a>k"
" Convert current line into checklist
let @c="^i[]  \<Esc>"
" Mark a check list item as complete
" todo :  What if the macro is used on the line which is not a checklist entry
let @d="^lix\<Esc>"
" Mark a check list item as incomplete
" todo: What if the macro is used on the which is not a checklist entry
let @u="^lx\<Esc>"
