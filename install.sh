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

# Ghostty config
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
GHOSTTY_CONFIG="$GHOSTTY_CONFIG_DIR/config"
mkdir -p "$GHOSTTY_CONFIG_DIR"
if [ -e "$GHOSTTY_CONFIG" ] && [ ! -L "$GHOSTTY_CONFIG" ]; then
  echo "Backing up existing ghostty config to $GHOSTTY_CONFIG.bak"
  mv "$GHOSTTY_CONFIG" "$GHOSTTY_CONFIG.bak"
fi
ln -sf "$DOTFILES_DIR/config/ghostty/config" "$GHOSTTY_CONFIG"
echo "Linked ghostty config -> $GHOSTTY_CONFIG"

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

# Fonts
FONTS_DIR="$HOME/Library/Fonts"
mkdir -p "$FONTS_DIR"
for font in "$DOTFILES_DIR"/fonts/*.ttf "$DOTFILES_DIR"/fonts/*.otf; do
  [ -e "$font" ] || continue
  cp -f "$font" "$FONTS_DIR/"
  echo "Installed font -> $FONTS_DIR/$(basename "$font")"
done

echo "Done."
