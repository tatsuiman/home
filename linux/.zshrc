#!/usr/bin/zsh
# language
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US.utf-8
export LC_ALL=en_US.utf-8

# zplug settings
if [[ ! -d ${HOME}/.zplug  ]]; then
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
    sleep 3
    source $HOME/.zplug/init.zsh && zplug update --self
else
    source $HOME/.zplug/init.zsh
fi

# コマンドのスペルを訂正
setopt correct

export LSCOLORS=ExfxcxdxbxGxDxabagacad
alias awsp="source _awsp"
if [[ `uname` == "Linux" ]]; then
    alias open='xdg-open'
    alias ls='ls --color=auto'
fi
if [[ `uname` == "Darwin" ]]; then
    alias ll='ls -lGF'
    alias ls='ls -GF'
    alias code='open -a "Cursor"'
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
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "junegunn/fzf"
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

# tmux上でCtrl-aやCtrl-eを使えるように
bindkey -e

# termitanl title
title() { printf "\033]0;$*\007"; }

# 実行時刻を記録するよう設定する
setopt extended_history

# safe mode
function no_history(){
    export HISTFILE=/dev/null
}

# fzf history
function select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history

# ヒストリー機能
HISTFILE=~/.zsh_history      # ヒストリファイルを指定
HISTSIZE=1000000             # ヒストリに保存するコマンド数
SAVEHIST=100000              # ヒストリファイルに保存するコマンド数
setopt hist_ignore_all_dups  # 重複するコマンド行は古い方を削除
setopt hist_ignore_dups      # 直前と同じコマンドラインはヒストリに追加しない
setopt share_history         # コマンド履歴ファイルを共有する
setopt append_history        # 履歴を追加 (毎回 .zsh_history を作るのではなく)
setopt inc_append_history    # 履歴をインクリメンタルに追加
setopt hist_no_store         # historyコマンドは履歴に登録しない
setopt hist_reduce_blanks    # 余分な空白は詰めて記録
setopt HIST_FIND_NO_DUPS     # 履歴検索中、(連続してなくとも)重複を飛ばす
setopt HIST_IGNORE_SPACE     # 行頭がスペースのコマンドは記録しない
export HISTORY_IGNORE='(for i in*|if *|git add*|git commit -m*|cd ..*|sudo rm *|rm *|export *KEY*|export *PASS*|open *|base64 -d*|\?\? *)'


# Developer settings
export EDITOR=vim

# python
# `brew install pyenv`
# `pyenv install 3.10.14`
# `pyenv global 3.10.14`

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# nodejs
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
if ! [ "$(command -v nvm)" ]; then
	curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
	sleep 3
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
	nvm install v20
	npm install -g awsp
fi

# starship
if ! [ "$(command -v starship)" ]; then
	curl -sS https://starship.rs/install.sh | sh
fi

# direnv
if ! [ "$(command -v direnv)" ]; then
	if [[ `uname` == "Darwin" ]]; then
		brew install direnv
	else
		sudo apt install direnv
	fi
fi

eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
. `brew --prefix`/etc/profile.d/z.sh

# shellscripts
export PATH="$PATH:$HOME/scripts/sh"
export PATH="$PATH:$HOME/scripts/python"

# Infra Tools
# terrafrom
# https://zenn.dev/bun913/articles/m1-mac-terraform-unstable
export GODEBUG=asyncpreemptoff=1
# mysql
export PATH="/usr/local/opt/mysql-client@8.0/bin:$PATH"
