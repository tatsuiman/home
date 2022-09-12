#!/usr/bin/zsh
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US.utf-8
export LC_ALL=en_US.utf-8

# zplug settings
if [[ ! -d ${HOME}/.zplug  ]]; then
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
    source $HOME/.zplug/init.zsh && zplug update --self
else
    source $HOME/.zplug/init.zsh
fi

# コマンドのスペルを訂正
setopt correct

export LSCOLORS=ExfxcxdxbxGxDxabagacad
alias vim='nvim'
alias view='nvim -R'
alias k='kubectl'
if [[ `uname` == "Linux" ]]; then
    alias open='xdg-open'
    alias ls='ls --color=auto'
fi
if [[ `uname` == "Darwin" ]]; then
    alias ll='ls -lGF'
    alias ls='ls -GF'
    export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools
    alias firefox='open -a /Applications/Firefox.app'
    alias chrome='open -a "/Applications/Google Chrome.app"'
    alias vlc='open -a "/Applications/VLC.app"'
    alias code='open -a "/Applications/Visual Studio Code.app"'
fi

# 補完機能を有効にする
autoload -Uz compinit
compinit -u

# 補完候補を詰めて表示
setopt list_packed

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# 補完候補一覧をカラー表示
autoload colors
zstyle ':completion:*' list-colors ${LSCOLORS}
zstyle ':completion:*:default' menu select=2



# 変更した時自動でコンパイル
if [ ${HOME}/.zshrc -nt ${HOME}/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

# misc plugins
zplug "zsh-users/zsh-completions"
zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "junegunn/fzf-bin", from:gh-r, as:command, rename-to:fzf
zplug "junegunn/fzf", as:command, use:bin/fzf-tmux
zplug "zsh-users/zsh-autosuggestions", use:"zsh-autosuggestions.zsh"

zstyle ':prezto:*:*' color 'yes'

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
zplug load

# 実行時刻を記録するよう設定する
setopt extended_history

# zshの履歴をfzfで検索
function fzf-select-history() {
    BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER" --prompt="History > ")
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-select-history
bindkey '^r' fzf-select-history

# safe mode
function no_history(){
	export HISTFILE=/dev/null
}
# termitanl title
title() { printf "\033]0;$*\007"; }

# ヒストリー機能
HISTFILE=~/.zsh_history      # ヒストリファイルを指定
HISTSIZE=1000000             # ヒストリに保存するコマンド数
SAVEHIST=100000              # ヒストリファイルに保存するコマンド数
setopt hist_expire_dups_first # 履歴を切り詰める際に、重複する最も古いイベントから消す
setopt hist_save_no_dups      # 履歴ファイルに書き出す際、新しいコマンドと重複する古いコマンドは切り捨てる
setopt hist_ignore_all_dups  # 重複するコマンド行は古い方を削除
setopt hist_ignore_dups      # 直前と同じコマンドラインはヒストリに追加しない
setopt share_history         # コマンド履歴ファイルを共有する
setopt append_history        # 履歴を追加 (毎回 .zsh_history を作るのではなく)
setopt inc_append_history    # 履歴をインクリメンタルに追加
setopt hist_no_store         # historyコマンドは履歴に登録しない
setopt hist_reduce_blanks    # 余分な空白は詰めて記録
setopt HIST_FIND_NO_DUPS     # 履歴検索中、(連続してなくとも)重複を飛ばす
setopt HIST_IGNORE_SPACE     # 行頭がスペースのコマンドは記録しない
export HISTORY_IGNORE='(for i in*|if *|git add*|git commit -m*|cd ..*|sudo rm *|rm *|export *KEY*|export *PASS*|base64 -d*)'


# Developer settings
## python
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    if [[ `uname` == "Darwin" ]]; then
        export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
    fi
    export WORKON_HOME=$HOME/.virtualenvs
    export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
    source /usr/local/bin/virtualenvwrapper.sh
fi

## nodejs
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
if ! [ "$(command -v nvm)" ]; then
	curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
	nvm install node
fi

## shell scripts
export PATH=$PATH:$HOME/bin/sh
if [ -d $HOME/bin/sh ] ; then
	for i in `ls $HOME/bin/sh/`
	do
		export PATH=$PATH:$HOME/bin/sh/$i
	done
fi
# other app
export PATH=$PATH:$HOME/bin/flutter/bin

# private rcfile
if [ -f $HOME/.zshrc_private ]; then
    source $HOME/.zshrc_private
fi
