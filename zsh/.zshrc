# Basic Zsh configuration

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

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

# Key bindings
bindkey -e

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Local binaries
export PATH="/home/adithya/.local/bin:$PATH"

# CUDA
export CUDA_PATH="/opt/cuda"
export PATH="$PATH:$CUDA_PATH/bin"
