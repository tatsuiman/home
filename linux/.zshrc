#!/usr/bin/zsh

if [[ ! -d ${HOME}/.zplug  ]]; then
	sudo apt-get install git curl
	curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
    source ~/.zplug/init.zsh && zplug update --self
else
    source ~/.zplug/init.zsh
fi

# 変更した時自動でコンパイル
if [ ${HOME}/.zshrc -nt ${HOME}/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=100000

export LSCOLORS=ExfxcxdxbxGxDxabagacad
zstyle ':completion:*' list-colors ${LSCOLORS}
zstyle ':completion:*:default' menu select=2

# Rename fzf-bin to fzf
zplug "junegunn/fzf-bin", from:gh-r, as:command, rename-to:fzf

#zplug "plugins/pip", from:oh-my-zsh
#zplug "plugins/autojump", from:oh-my-zsh

zplug "lib/theme-and-appearance", from:oh-my-zsh
#zplug "lib/key-bindings", from:oh-my-zsh
zplug "lib/history", from:oh-my-zsh
zplug "psprint/history-search-multi-word"
bindkey "^R" history-search-multi-word

zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
bindkey '^ ' autosuggest-accept

#zplug "themes/mh", from:oh-my-zsh
zplug "themes/tjkirch", from:oh-my-zsh

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
	printf "Install? [y/N]: "
	if read -q; then
		echo; zplug install
	fi
fi

# Then, source plugins and add commands to $PATH
zplug load
#eval "$(fasd --init auto)"
#
umask 0002
# Add PATH
typeset -U path PATH
export PATH=$PATH:$HOME/bin:$HOME/bin/sh:$HOME/bin/python:$HOME/bin/perl

if [ -d $HOME/bin/pentest/network ] ; then
	for i in `ls $HOME/bin/pentest/network/`
	do
		export PATH=$PATH:$HOME/bin/pentest/network/$i
	done
fi

# OS Settings
if [ `uname` = "Darwin" ]; then
	alias ls='ls -G'
elif [ `uname` = "Linux" ]; then
	export LANG=C
fi
if [ "$(locate -e ja_JP.UTF-8|wc -l)" -ne 0 ];then
	export LANG=ja_JP.UTF-8
fi

# alias
alias nkf.utf8='nkf -w --overwrite'
alias nkf.sjis='nkf -s --overwrite'
alias objdump='objdump -M intel'
alias xxd='xxd -g 1'
alias vi='vim -u NONE --noplugin'
alias pip='pip --proxy $HTTP_PROXY'
alias pip3='pip3 --proxy $HTTP_PROXY'

# rbenv config
if [[ ! -d ${HOME}/.rbenv  ]]; then
	sudo apt-get -y install autoconf bison build-essential curl git-core libapr1 libaprutil1 libcurl4-openssl-dev libgmp3-dev libpcap-dev libpq-dev libreadline6-dev libsqlite3-dev libssl-dev libsvn1 libtool libxml2 libxml2-dev libxslt-dev libyaml-dev locate ncurses-dev openssl wget xsel zlib1g zlib1g-dev
	git clone https://github.com/sstephenson/rbenv.git ${HOME}/.rbenv
	git clone https://github.com/sstephenson/ruby-build.git ${HOME}/.rbenv/plugins/ruby-build
fi
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
