#!/bin/bash

set -e  # Exit on error
set -o pipefail  # Catch errors in piped commands

echo "Starting automated setup..."

# Update and install prerequisites
echo "Updating package list..."
sudo apt update -y && sudo apt upgrade -y

# Install Neovim
echo "Installing Neovim..."
sudo apt remove vim -y
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
fi
brew install neovim
sudo ln -sf "$(which nvim)" /usr/bin/vim

# Install tmux
echo "Installing tmux..."
sudo apt install tmux -y

# Install eza
echo "Installing eza..."
brew install eza

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" </dev/null
else
  echo "Oh My Zsh already installed."
fi

# Clone and setup dotfiles
echo "Cloning dotfiles repository..."
DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
  git clone https://github.com/ItzNesbro/dotfiles "$DOTFILES_DIR"
else
  echo "Dotfiles repository already cloned."
fi

echo "Setting up configuration files..."
mkdir -p ~/.config
cp -r "$DOTFILES_DIR/.config/nvim" ~/.config/nvim
rm -rf ~/.config/tmux
cp -r "$DOTFILES_DIR/.config/tmux" ~/.config/tmux

# Update zshrc with aliases and plugins
echo "Configuring .zshrc..."
cat <<'EOF' >> ~/.zshrc

# Define useful aliases
alias cl="clear"
alias ll="eza -l -g --icons"
alias la="ll -a"
alias g="git"
alias gc="git add . && czg"

# Load zsh plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh
EOF

# Install zsh-autosuggestions
echo "Installing zsh-autosuggestions..."
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
else
  echo "zsh-autosuggestions already installed."
fi

# Install zsh-syntax-highlighting
echo "Installing zsh-syntax-highlighting..."
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
else
  echo "zsh-syntax-highlighting already installed."
fi

# Source .zshrc
echo "Sourcing .zshrc..."
source ~/.zshrc

# Install czg and minimal-git-cz
echo "Installing czg and minimal-git-cz..."
npm install -g minimal-git-cz
