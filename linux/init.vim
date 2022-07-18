" 環境設定
set autoindent
set smartindent
set encoding=utf-8
set fileencodings=utf-8,iso-2022-jp,sjis
set ff=unix "改行をUNIX形式に
set noswapfile "スワップファイルを作らない
set nocompatible "viとの互換モードをOFF
set number "行番号を表示する
set mouse=a "マウスで選択できるようにする
set autoindent "オートインデントする
set incsearch "インクリメンタルサーチ
set showmatch "対応する括弧のハイライト表示する
set showmode "モード表示する
set title "編集中のファイル名を表示する
set ruler "ルーラーの表示する
set tabstop=4 "タブ文字数を4にする
set modifiable
set write
set list
set listchars=tab:»\ ,eol:↩ "改行とtabの表示
set shiftwidth=4
set title
set laststatus=2
set showcmd
set display=lastline
set nobackup
set nocursorline
set noexpandtab
set hlsearch
retab 4
au InsertEnter,InsertLeave * set cursorline!
filetype plugin indent on 
syntax on

" プラグイン設定
call plug#begin()
  Plug 'ntk148v/vim-horizon'
  Plug 'preservim/nerdtree'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
"  Plug 'sheerun/vim-polyglot'
call plug#end()

nnoremap <C-t> :NERDTreeToggle<CR>
" Start NERDTree when Vim is started without file arguments.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

set termguicolors

colorscheme horizon

" lightline
let g:lightline = {}
let g:lightline.colorscheme = 'horizon'
