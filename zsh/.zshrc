# Basic Zsh configuration

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt AUTO_CD
# Prompt (Starship)
eval "$(starship init zsh)"

# Zoxide - smart cd replacement
eval "$(zoxide init zsh --cmd cd)"

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias ..='cd ..'
alias vim='nvim'
alias ssh="kitty +kitten ssh"

# Key bindings
bindkey -e
bindkey "\e[1;5D" backward-word
bindkey "\e[1;5C" forward-word

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Local binaries
export PATH="/home/adithya/.local/bin:$PATH"
export EDITOR="nvim"

# CUDA
export CUDA_PATH="/opt/cuda"
export PATH="$PATH:$CUDA_PATH/bin"
# YAZI shortcut
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}
