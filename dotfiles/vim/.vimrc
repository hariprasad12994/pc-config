"Set nocompatible to ward off unexpected things the distro might have made,
" as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto indenting for each filetype, and
" for plugind that are filetype specific
filetype indent plugin on

" Enable syntax highlighting
syntax on

" Leader is space, matching the nvim config
let mapleader = ' '

" Disable audio bells
set noerrorbells

" Set hidden so that while switching between buffers and tabs vim does'nt 
" prompt to save or move with the override ! command
set hidden 

" Indentation settings for using 4 spaces instead of tabs
" Do not change 'tabstop' from its default value of 8 with this setup
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smarttab

" Enable smart indentation
set smartindent
set autoindent
set wrap
" Mappings carried over from the nvim config, so muscle memory survives the
" fallback. Only the ones that need no plugin: window and buffer movement,
" explicit clipboard yank/put, select-all.
nnoremap <C-h> :wincmd h<CR>
nnoremap <C-j> :wincmd j<CR>
nnoremap <C-k> :wincmd k<CR>
nnoremap <C-l> :wincmd l<CR>
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <leader>a :keepjumps normal! ggVG<CR>
nnoremap cp "+y
xnoremap cp "+y
nnoremap cv "+p
xnoremap cv "+p

" In case of indentation failure, a key for full file indentation.
" Not <C-i>: that is vim's jump-forward, the counterpart to <C-o>, and it also
" shares a keycode with <Tab>. nnoremap rather than noremap because gg=G only
" means anything in normal mode.
nnoremap <leader>= gg=G

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
set nohlsearch

" Enable pasting from external clipboard
set clipboard=unnamedplus

" Enable block folding in case of code blocks
set nofoldenable
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

" No plugins, deliberately. This is the fallback editor, and its whole value is
" working from a bare vim on any machine: no network, no :PlugInstall, no
" compile step. Everything the old plugin list provided - completion, a file
" tree, fuzzy find - lives in the nvim config instead, and the plugin block here
" only ever meant 23 errors on startup whenever vim-plug was not installed.
if has('termguicolors')
  set termguicolors
endif
set background=dark

" retrobox ships with vim 9 and is its gruvbox derivative, so the fallback looks
" like the rest of the setup without pulling anything in.
colorscheme retrobox

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
