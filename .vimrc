set nocompatible

"" General
color desert
filetype on                                                           " Enable filetype detection
filetype indent on                                                    " Enable filetype-specific indenting
filetype plugin on                                                    " Enable filetype-specific plugins
scriptencoding utf-8
syntax on

"" Options
set autoread                                                            " watch for file changes
set backspace=indent,eol,start                                          " backspace for dummys
set cindent                                                             " automatically indent to the c standard
set copyindent                                                          " use existing indents for new indents
set cursorline                                                          " highlight the current line
set directory=/tmp                                                      " directory for swp files
set expandtab
set fileformats=unix,dos,mac                                            " support all three newline formats
set guifont=Consolas:h10:cANSI
set history=200
set hlsearch                                                            " enable search highlighting
set incsearch                                                           " start searching while typing
set ignorecase                                                          " case insensitive searching
set list                                                                " show invisible characters
set listchars=tab:>.,trail:.,extends:#,nbsp:.                           " highlight problematic whitespace
set matchtime=5                                                         " blink matching chars for .x seconds
set more                                                                " use more prompt
set mouse=a                                                             " automatically enable mouse
set nobackup
set noerrorbells                                                        " don't whine
set nostartofline                                                       " leave my cursor position alone!
set nowrap
set number                                                              " show line numbers
set ruler
set scrolloff=10                                                        " keep 10 lines when scrolling
set shiftwidth=4                                                        " how many spaces for autoIndent
set showmatch                                                           " show matching brackets.
set showmode                                                            " show the current mode
set softtabstop=4                                                       " let backspace delete indent
set spell                                                               " enable spell checking
set tabstop=4                                                           " how many spaces for a tab
set textwidth=250                                                       " we like 250 columns
set undolevels=1000                                                     " 1000 undos
set viminfo=                                                            " don't use or save viminfo files
set visualbell t_vb=                                                    " don't make faces
set whichwrap=h,l,<,>                                                   " wrap on cursor keys and h, l

"" Key mappings
nmap <silent> <leader>/ :nohlsearch<CR>
cmap w!! w !sudo tee % >/dev/null

" Status line config
if has('statusline')
    set laststatus=2
    " Broken down into easily includeable segments
    set statusline=%<%f\    " Filename
    set statusline+=%w%h%m%r " Options
    set statusline+=\ [%{&ff}/%Y]            " filetype
    set statusline+=\ [%{getcwd()}]          " current dir
    set statusline+=\ [A=\%03.3b/H=\%02.2B] " ASCII / Hexadecimal value of char
    set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
endif

if has('gui_running')
    set guioptions-=T          	" remove the toolbar
    set lines=40               	" 40 lines of text instead of 24,
else
    set term=builtin_ansi       " Make arrow and other keys work
endif
