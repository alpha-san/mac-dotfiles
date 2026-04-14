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

# Claude Code config
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR"
for f in settings.json CLAUDE.md; do
  target="$CLAUDE_DIR/$f"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Backing up existing $target to $target.bak"
    mv "$target" "$target.bak"
  fi
  ln -sf "$DOTFILES_DIR/config/claude/$f" "$target"
  echo "Linked claude $f -> $target"
done

echo "Done."
