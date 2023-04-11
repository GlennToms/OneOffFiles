# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

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
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*) ;;
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

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias df='df -h'
alias du='du -h'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

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
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Check if tmux is installed and no tmux or screen session is already running
if command -v tmux &>/dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    if [ ! "$TERM_PROGRAM" = "vscode" ]; then
        # Check if any tmux sessions exist
        if tmux list-sessions >/dev/null 2>&1; then
            # Attach to the first tmux session in the list
            tmux attach-session -t $(tmux list-sessions | head -n 1 | cut -d: -f1)
        else
            # Start a new tmux session
            tmux new-session
        fi
    fi
fi

# Define a function to set the PS1 prompt for the terminal
function my_prompt {
    # Define some color codes for use in the PS1 prompt
    local WHITE="\[\033[0;37m\]"
    local PURPLE="\[\033[0;35m\]"
    local CYAN="\[\033[0;36m\]"
    local YELLOW="\[\033[0;33m\]"
    local GREEN="\[\033[0;32m\]"
    local RED="\[\033[0;31m\]"
    local RESET="\[\033[0m\]"

    # Define some variables to be used in the PS1 prompt
    local last_color=""
    local colors=("$PURPLE" "$CYAN" "$YELLOW")
    local color_index=0

    # Check if the current user is the root user (UID 0)
    if [[ $EUID -eq 0 ]]; then
        # If they are, set the PS1 prompt accordingly
        PS1="$RED[$RED\u$CYAN@$YELLOW\h$RED]─[$RESET"
    else
        # If they aren't, set the PS1 prompt accordingly
        PS1="$WHITE[$PURPLE\u$CYAN@$YELLOW\h$WHITE]─[$RESET"
    fi

    # Get the current working directory and abbreviate it if it is in the user's home directory
    local pwd="$PWD"
    if [[ $pwd == $HOME* ]]; then
        pwd="~${pwd#$HOME}"
    fi

    # Abbreviate the current working directory if it is longer than 24 characters
    if [[ "${#pwd}" -gt 24 ]]; then
        pwd=$(basename "$pwd")
    fi

    # Split the abbreviated working directory into its individual components
    local IFS='/'
    read -ra ADDR <<<"$pwd"

    # Loop over each component of the abbreviated working directory and set its color in the PS1 prompt
    for i in "${ADDR[@]}"; do
        # if [[ $i == "" ]] && [[ $i == 0 ]]; then
        #     PS1+="/"
        #     continue
        # fi

        # Set the color for this component of the working directory
        local color="${colors[$color_index]}"

        # If this is the first component of the working directory and it starts with a slash, add the slash and set the color
        if [[ "${pwd:0:1}" == "/" ]] && [[ $i == 0 ]]; then
            PS1+="/$color$i"
        else
            # Otherwise, just add the component and set the color
            PS1+="$color$i$RESET/"
        fi

        # Increment the color index and reset it to 0 if it exceeds the number of available colors
        ((color_index++))
        if ((color_index >= ${#colors[@]})); then
            color_index=0
        fi
    done

    if [[ "$PWD" == "/" ]]; then
        PS1+="/"
    fi

    # Remove any trailing slash from the working directory component of the PS1 prompt
    PS1="${PS1%/}"

    # Add the appropriate symbol to the end of the PS1 prompt depending on whether the user is the root user or not
    if [[ $EUID -eq 0 ]]; then
        PS1+="$RED]#"
    else
        PS1+="$WHITE]$GREEN\\$"
    fi

    # Add the reset code to the end of the PS1 prompt
    PS1+="$RESET "
}
# Set the PROMPT_COMMAND environment variable to call the my_prompt function
PROMPT_COMMAND=my_prompt
