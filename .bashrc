# ~/.bashrc executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
# shopt -s globstar

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# Uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
# force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
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
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Function to get a random foreground color code in the range 100-200
random_color() {
    local color_code=$((100 + RANDOM % 101))  # Range from 100 to 200
    echo -n "$(tput setaf $color_code)"
}

# Function to get a random emoji
random_emoji() {
    emojis=("🪨" "🌾" "💐" "🌷" "🪷" "🌹" "🥀" "🌺" "🌸" "🪻" "🌼" "🌻" "🌞" "🌝" "🌛" "🌜" "🌚" "🌕" "🌖" "🌗" "🌘" "🌑" "🌒" "🌓" "🌔" "🌙" "🌎" "🌍" "🌏" "🪐" "💫" "⭐️" "🌟" "✨" "⚡️" "☄️" "💥" "🔥" "🌪" "🌈" "😀" "😃" "😄" "😁" "😆" "😅" "😂" "🤣" "😊" "😇" "🙂" "🙃" "😉" "😌" "😍" "🥰" "😘" "😗" "😙" "😚" "🌐" "☁️" "🔌" "💻" "📱" "🖥️" "🖨️" "🖱️" "⌨️" "📶" "📡" "🔋" "🔧" "⚙️" "💡" "🔒" "🔓" "📟" "📠" "🕹️" "🎮" "📺" "📷" "📸" "📹" "🎥" "📞" "☎️" "🔊" "🔇" "🔈" "🔉" "🔔" "📲" "💾" "💿" "📀" "🗂️" "💼" "📂" "🗄️" "🗃️" "🗑️" "🛠️" "🧰" "🧲" "🧪" "📊" "📈" "📉" "📋" "📝" "🗒️" "📑" "📘" "📚" "📰" "🔍" "🗜️" "💸")
    echo -n "${emojis[$((RANDOM % ${#emojis[@]}))]}"
}

# Function to determine if the last command was successful
command_status() {
    if [ $1 -eq 0 ]; then
        echo -n "✔"
    else
        echo -n "✘"
    fi
}

# Check DNS function
check_dns() {
    curl -s --max-time 1 https://www.google.com > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✔"
    else
        echo "✘"
    fi
}

# Check internet function
check_internet() {
    timeout 1s ping -c 1 8.8.8.8 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✔"
    else
        echo "✘"
    fi
}

# Function to get the current time in seconds
current_time() {
    date +"%s"
}

# Define a unique symbol for root
root_symbol() {
    echo -n "♔"  # You can choose any symbol like "⚡", "★", etc.
}

# Initialize global variables to store the last check time and status
LAST_CHECK_TIME=0
DNS_STATUS="✘"
INTERNET_STATUS="✘"

# Use a helper function to set PS1
update_ps1() {
    local exit_status=$1

    # Get the current time in seconds
    local now=$(current_time)

    # Perform DNS and internet checks only every 30 seconds
    if [ $((now - LAST_CHECK_TIME)) -ge 60 ]; then
        DNS_STATUS=$(check_dns)
        if [ "$DNS_STATUS" = "✘" ]; then
            INTERNET_STATUS=$(check_internet)
        else
            INTERNET_STATUS="✔"
        fi
        LAST_CHECK_TIME=$now
    fi

    # Set random color
    local color_code=$((100 + RANDOM % 101))
    local color_code_str=$(tput setaf $color_code)

    # Build PS1
    PS1="\[$(tput blink)\]$(random_emoji)\[$(tput sgr0)\]\[${color_code_str}\] $(command_status $exit_status) \$(date +%T) \w (\$(date +'%a %b %g')) 🗄️ $DNS_STATUS 🌐 $INTERNET_STATUS \n--> $(root_symbol) \[$(tput sgr0)\] "
}

# PROMPT_COMMAND to capture the exit status and call update_ps1
PROMPT_COMMAND='update_ps1 $?'

# Some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands. Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "Command finished"'
