# If not running interactively, don't do anything
if [[ -n "$PS1" ]]; then

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    USER_COLOR='\[\033[01;31m\]' # red
    HOST_COLOR='\[\033[01;32m\]' # green
	PWD_COLOR='\[\033[01;34m\]' # blue
    RESET_COLOR='\[\033[00m\]'
	if [ "$UID" -eq "0" ];then
		PS1="${debian_chroot:+$debian_chroot)}${USER_COLOR}\u${HOST_COLOR}@\h:${PWD_COLOR}\w${RESET_COLOR}# "
	else
		PS1="${debian_chroot:+$debian_chroot)}${USER_COLOR}\u${HOST_COLOR}@\h:${PWD_COLOR}\w${RESET_COLOR}\$ "
	fi
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
#if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
#    . /etc/bash_completion
#fi
  export HISTCONTROL=ignoreboth
fi
function share_history(){
history -a
history -c
history -r
}
PROMPT_COMMAND='share_history'
shopt -u histappend
stty stop undef


################# add PATH ##################
export PATH=`echo $PATH | tr ':' '\n' | sort -u | paste -d: -s -`;
# Java
#export JAVA_HOME=/usr/lib/jvm/java-7-oracle/jre/
#export JRE_HOME=$HOME/bin/java/jre
#export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
# bin
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin
export PATH=$PATH:$HOME/bin:$HOME/bin/sh:$HOME/bin/python:$HOME/bin/perl
# tools
if [ -d $HOME/bin/tools ] ; then
	for i in `ls $HOME/bin/tools/`
	do
		export PATH=$PATH:$HOME/bin/tools/$i
	done
fi
################# add PATH ##################

if [ `uname` = "Darwin" ]; then
	alias ls='ls -G'
elif [ `uname` = "Linux" ]; then
	#server
	case $TERM in
	linux) LANG=C ;;
	*) LANG=ja_JP.UTF-8 ;;
	esac
fi

# alias
alias nkf.utf8='nkf -w --overwrite'
alias nkf.sjis='nkf -s --overwrite'
alias objdump='objdump -M intel'
alias shutdown.now='sudo shutdown -h now'
alias w3m.tor='torsocks w3m https://www.google.co.jp'
alias w3m.home='w3m https://www.google.co.jp'
alias vi='vim -u NONE --noplugin'
alias xxd='xxd -g 1'
