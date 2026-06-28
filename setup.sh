#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e 

# Helper function to print step headers
print_step() {
    echo -e "\n\033[1;34m===> $1\033[0m"
}

# ---------------------------------------------------------
# STEP 1: System Packages (Official Repos & AUR)
# ---------------------------------------------------------
install_packages() {
    print_step "Installing System Packages..."
    
    # Official repos (using --needed to skip already installed packages)
    sudo pacman -Syu --needed \
        git \
        curl \
        stow \
	npm \
        zsh \
        unzip \
        neovim \
	btop \
	spotify-launcher \
	obsidian \
	pass \
	opencode \
	discord \
	zellij \
	tree \
	fzf \
	zoxide \
	ripgrep \
	fd \
	wl-clipboard \
	cuda \
	python-pip \
	starship \
	zsh-syntax-highlighting \
	zsh-autosuggestions \
	openconnect

    # AUR Packages (EndeavourOS comes with yay pre-installed)
    print_step "Installing AUR Packages..."
    yay -S --needed ttf-jetbrains-mono-nerd
}

# ---------------------------------------------------------
# STEP 2: Restore Configurations using GNU Stow
# ---------------------------------------------------------
setup_git() {
    print_step "Configuring Git..."
    git config --global user.name "adithyaka3"
    git config --global user.email "adithyaka@iisc.ac.in"
    git config --global init.defaultBranch main
}

setup_obsidian() {
    print_step "Setting up Obsidian vault..."
    if [ ! -d ~/Obsidian ]; then
        git clone https://github.com/adithyaka3/Obsidian.git ~/Obsidian
    else
        echo "Obsidian vault already exists."
    fi
}

setup_dotfiles() {
    print_step "Symlinking configurations with Stow..."
    
    # Navigate to the dotfiles directory (assuming script is run from there)
    cd ~/dotfiles
    
    # Run stow for each directory. This creates symlinks in your Home directory.
    stow nvim
    stow zsh
    stow opencode-skills
}

# ---------------------------------------------------------
# STEP 3: Setup External Tools & Plugins
# ---------------------------------------------------------
setup_vimplug() {
    print_step "Setting up Vim-Plug for Neovim..."
    if [ ! -f "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" ]; then
        sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    else
        echo "Vim-Plug is already installed."
    fi
}

setup_cpos() {
    if command -v cpos &>/dev/null; then
        echo "CPOS is already installed."
    else
        print_step "Installing CPOS..."
        curl -fsSL https://raw.githubusercontent.com/Soham109/cpos/main/install.sh | sh
    fi
}

setup_codegraph() {
    if command -v codegraph &>/dev/null; then
        echo "CodeGraph is already installed."
    else
        print_step "Installing CodeGraph..."
        curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
    fi
}

setup_tools() {
    setup_vimplug
    setup_cpos
    setup_codegraph
}

setup_python() {
    print_step "Setting up Python environment..."
    if [ ! -d ~/.venv ]; then
        python -m venv ~/.venv
        echo "Created virtual environment at ~/.venv"
    else
        echo "Virtual environment already exists."
    fi
    ~/.venv/bin/pip install pynvim
    echo "pynvim installed in ~/.venv"
}

# ---------------------------------------------------------
# STEP 4: Shell & Environment Setup
# ---------------------------------------------------------
setup_shell() {
    print_step "Changing default shell to Zsh..."
    # Only change if the current shell is not already zsh
    if [ "$SHELL" != "/usr/bin/zsh" ]; then
        chsh -s $(which zsh)
    else
        echo "Zsh is already the default shell."
    fi
}

setup_cuda() {
    print_step "Configuring CUDA environment..."
    if ! grep -q "CUDA_PATH" ~/.zshrc 2>/dev/null; then
        {
            echo ""
            echo "# CUDA"
            echo 'export CUDA_PATH="/opt/cuda"'
            echo 'export PATH="$PATH:$CUDA_PATH/bin"'
        } >> ~/.zshrc
        echo "CUDA paths added to ~/.zshrc"
    else
        echo "CUDA paths already configured in ~/.zshrc"
    fi
}

# =========================================================
# EXECUTION COMMANDS
# =========================================================

echo "Starting EndeavourOS Setup Script..."

# Comment out any step you want to skip during a run
install_packages
setup_git
setup_obsidian
setup_dotfiles
setup_tools
setup_python
setup_shell
setup_cuda

print_step "Setup Complete! Restart your terminal for changes to take effect."
