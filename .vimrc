""" general
set nocompatible
set hidden
set encoding=utf-8
set autoindent noexpandtab tabstop=4 shiftwidth=4
syntax on
set autoread
set expandtab
set history=200
set nobackup
set viminfo=
filetype plugin indent on
set directory=/tmp

" are these needed?
set shortmess+=c
set cursorline
set fileformats=unix,dos,mac
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.
set matchtime=0
set noerrorbells

" view
set nowrap
set number
set ruler
set showmatch
set showmode

if has('statusline')
    set laststatus=2
    set statusline=

    set statusline+=[%n]\ 
    set statusline+=%-40F\ 
    set statusline+=%=%y%*%*\ 
    set statusline+=%10((%l,%c)%)\ 
    set statusline+=%p%%\ 
endif       

" search
set incsearch
set ignorecase

" training wheels
set backspace=indent,eol,start
set whichwrap=h,l,<,>

" undo
if !isdirectory($HOME."/.vim/undo")
    call mkdir($HOME."/.vim/undo", "p", 0700)
endif
set undodir=$HOME/.vim/undo
set undofile

" use vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'tomasiser/vim-code-dark'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-eunuch'

call plug#end()

" install plugins automatically
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif

" color
silent! colorscheme codedark
