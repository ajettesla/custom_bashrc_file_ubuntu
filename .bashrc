# ~/.bashrc: executed by bash(1) for non-login shells.

case $- in
    *i*) ;;
      *) return;;
esac

# History settings
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

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

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Random color generator
random_color() {
    local color_code=$((100 + RANDOM % 101))
    echo -n "$(tput setaf $color_code)"
}

# Random emoji
random_emoji() {
    emojis=("🌐" "🔧" "💻" "📱" "⚙️" "💡" "🔒" "📟" "📠" "🕹️" "🎮" "📺" "📷" "📡" "🔋" "🔌" "📂" "🛠️" "🧰")
    echo -n "${emojis[$((RANDOM % ${#emojis[@]}))]}"
}

# Command status
command_status() {
    [ $1 -eq 0 ] && echo -n "✔" || echo -n "✘"
}

# DNS & internet checks
check_dns() {
    timeout 1s ping -c 1 google.com > /dev/null 2>&1 && echo "✔" || echo "✘"
}
check_internet() {
    timeout 1s ping -c 1 8.8.8.8 > /dev/null 2>&1 && echo "✔" || echo "✘"
}

current_time() {
    date +"%s"
}

root_symbol() {
    [ "$EUID" -eq 0 ] && echo -n "♔" || echo -n ""
}

# Caches
CPU_CACHE=""
MEM_CACHE=""
NET_CACHE=""
LAST_STATS_TIME=0
DNS_STATUS="✘"
INTERNET_STATUS="✘"
LAST_CHECK_TIME=0

# Cache system stats every 5 seconds
cache_stats() {
    local now=$(date +%s)
    if [ $((now - LAST_STATS_TIME)) -ge 5 ]; then
        CPU_CACHE=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.1f%%", 100 - $8}')
        MEM_CACHE=$(free -m | awk '/Mem:/ {printf "%dMB/%.0fMB (%.1f%%)", $3, $2, $3/$2 * 100}')
        local interface=$(ip route | grep '^default' | awk '{print $5}')
        if [[ -n "$interface" ]]; then
            RX=$(cat /sys/class/net/$interface/statistics/rx_bytes)
            TX=$(cat /sys/class/net/$interface/statistics/tx_bytes)
            NET_CACHE=$(printf "↓%0.1fMB ↑%0.1fMB" $(echo "$RX / 1024 / 1024" | bc -l) $(echo "$TX / 1024 / 1024" | bc -l))
        else
            NET_CACHE="NoNet"
        fi
        LAST_STATS_TIME=$now
    fi
}

# Update PS1
update_ps1() {
    local exit_status=$1
    local now=$(current_time)

    cache_stats

    if [ $((now - LAST_CHECK_TIME)) -ge 60 ]; then
        DNS_STATUS=$(check_dns)
        INTERNET_STATUS=$(check_internet)
        LAST_CHECK_TIME=$now
    fi

    local color_code_str=$(random_color)
    local cpu_usage=$CPU_CACHE
    local mem_usage=$MEM_CACHE
    local net_usage=$NET_CACHE

    if [ -n "$VIRTUAL_ENV" ]; then
        env_name="($(basename $VIRTUAL_ENV)) "
    else
        env_name=""
    fi

    PS1="\[$(tput blink)\]$(random_emoji)\[$(tput sgr0)\]\[$color_code_str\] \
$(command_status $exit_status) \$(date +%T) \w (\$(date +'%a %b %d')) \
🗄️ $DNS_STATUS 🌐 $INTERNET_STATUS 🧠 $cpu_usage 💾 $mem_usage 📶 $net_usage \
\n--> $env_name $(root_symbol) \[$(tput sgr0)\] "
}

PROMPT_COMMAND='update_ps1 $?'

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# BCC tools path
bcctools=/usr/share/bcc/tools
bccexamples=/usr/share/bcc/examples
export PATH=$bcctools:$bccexamples:$PATH

# Notify when long commands finish
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "Command finished"'
