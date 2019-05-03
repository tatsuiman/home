#!/usr/bin/zsh
# zplug settings
if [[ ! -d ${HOME}/.zplug  ]]; then
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
    source $HOME/.zplug/init.zsh && zplug update --self
else
    source $HOME/.zplug/init.zsh
fi
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US.utf-8
export LC_ALL=en_US.utf-8
export LSCOLORS=ExfxcxdxbxGxDxabagacad

# ヒストリー機能
# command r でコマンド履歴を辿るのでいっぱいにしとく
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
zstyle ':completion:*' list-colors ${LSCOLORS}
zstyle ':completion:*:default' menu select=2

alias ls='ls --color=auto'

# 変更した時自動でコンパイル
if [ ${HOME}/.zshrc -nt ${HOME}/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

# misc plugins
zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-completions"
zplug "junegunn/fzf-bin", from:gh-r, as:command, rename-to:fzf
zplug "junegunn/fzf", use:"shell/*.zsh"
zplug "zsh-users/zsh-autosuggestions"
bindkey '^ ' autosuggest-accept

# Container related plugins
zplug "Dbz/zsh-kubernetes"
zplug "ahmetb/kubectx", use:kubectx, as:command
zplug "ahmetb/kubectx", use:kubens, as:command
zplug "plugins/kube-ps1", from:oh-my-zsh, use:"kube-ps1.plugin.zsh"
zplug "webyneter/docker-aliases"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
zplug load

# Developer settings
# python
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    export WORKON_HOME=$HOME/.virtualenvs
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    source /usr/local/bin/virtualenvwrapper.sh
fi

# k8s
if [[ ! -d ${HOME}/.stern  ]]; then
    mkdir -p ${HOME}/.stern
    curl -L https://github.com/wercker/stern/releases/download/1.10.0/stern_linux_amd64 -o $HOME/.stern/stern
    chmod 755 $HOME/.stern/stern
fi
export PATH=$PATH:$HOME/.stern
source <(kubectl completion zsh)
source <(stern --completion=zsh)
alias k='kubectl'

# K8s
function k8s_token(){
	kubectl -n kube-system get secret $(kubectl -n kube-system get secret | grep default-token | awk '{print $1}') -o json | jq .data.token | tr -d '"'
}

function k8s_api(){
	KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)
	curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
      https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/$1
}
