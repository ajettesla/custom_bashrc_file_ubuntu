# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# Check window size and update LINES & COLUMNS
shopt -s checkwinsize

# Enable color prompt if terminal supports it
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# Set prompt appearance
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

# Set xterm title
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

# Enable color support for ls, grep, and other commands
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Generate a random color for the prompt
random_color() {
    local color_code=$((100 + RANDOM % 101))  # Range: 100-200
    echo -n "$(tput setaf $color_code)"
}

# Generate a random emoji
random_emoji() {
    emojis=("🌐" "🔧" "💻" "📱" "⚙️" "💡" "🔒" "📟" "📠" "🕹️" "🎮" "📺" "📷" "📡" "🔋" "🔌" "📂" "🛠️" "🧰")
    echo -n "${emojis[$((RANDOM % ${#emojis[@]}))]}"
}

# Show command success (✔) or failure (✘)
command_status() {
    [ $1 -eq 0 ] && echo -n "✔" || echo -n "✘"
}

# Check internet connection
check_dns() {
    timeout 1s ping -c 1 google.com > /dev/null 2>&1 && echo "✔" || echo "✘"
}

check_internet() {
    timeout 1s ping -c 1 8.8.8.8 > /dev/null 2>&1 && echo "✔" || echo "✘"
}

# Get current time in seconds
current_time() {
    date +"%s"
}

# Root user symbol
root_symbol() {
    [ "$EUID" -eq 0 ] && echo -n "♔" || echo -n ""
}

# Variables for network status updates
LAST_CHECK_TIME=0
DNS_STATUS="✘"
INTERNET_STATUS="✘"

# Update PS1 dynamically
update_ps1() {
    local exit_status=$1
    local now=$(current_time)

    # Check network status every 60 seconds
    if [ $((now - LAST_CHECK_TIME)) -ge 60 ]; then
        DNS_STATUS=$(check_dns)
        INTERNET_STATUS=$(check_internet)
        LAST_CHECK_TIME=$now
    fi

    # Set random color
    local color_code_str=$(random_color)

    # Show virtual environment name if active
    if [ -n "$VIRTUAL_ENV" ]; then
        env_name="($(basename $VIRTUAL_ENV)) "
    else
        env_name=""
    fi

    # Update PS1
    PS1="\[$(tput blink)\]$(random_emoji)\[$(tput sgr0)\]\[$color_code_str\] $(command_status $exit_status) \$(date +%T) \w (\$(date +'%a %b %d')) 🗄️ $DNS_STATUS 🌐 $INTERNET_STATUS \n--> $env_name$(whoami)$(root_symbol) \[$(tput sgr0)\] "
}

# Set prompt command to update PS1
PROMPT_COMMAND='update_ps1 $?'

# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alert alias for long-running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "Command finished"'
