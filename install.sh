#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Neovim config
NVIM_CONFIG_DIR="$HOME/.config/nvim"
if [ -d "$NVIM_CONFIG_DIR" ] && [ ! -L "$NVIM_CONFIG_DIR" ]; then
  echo "Backing up existing neovim config to $NVIM_CONFIG_DIR.bak"
  mv "$NVIM_CONFIG_DIR" "$NVIM_CONFIG_DIR.bak"
fi
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/config/nvim" "$NVIM_CONFIG_DIR"
echo "Linked neovim config -> $NVIM_CONFIG_DIR"

echo "Done."
