set background=dark " 背景色：黒
set guioptions-=T "GUIのツールバーを消す
set showtabline=2 " タブを常に表示

hi clear Pmenu
hi clear PmenuSel
hi clear PmenuSbar
hi clear PmenuThumb
hi Pmenu guibg=darkgreen guifg=white
hi PmenuSel guibg=red guifg=green
hi PmenuSbar guibg=#333333
hi PmenuThumb guibg=white

" OSの判定
if has('win32')
	set lines=60 columns=120 " ウィンドウサイズを指定
	set transparency=221
	set guifont=Monospace\ 8
elseif has('mac')
	set lines=45 columns=150
	set guifont=Andale\ Mono:h15
else
	set lines=45 columns=150
	set guifont=Monospace\ 12
endif

