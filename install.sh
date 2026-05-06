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
ln -shf "$DOTFILES_DIR/config/nvim" "$NVIM_CONFIG_DIR"
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
for f in settings.json CLAUDE.md statusline-command.sh; do
  target="$CLAUDE_DIR/$f"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Backing up existing $target to $target.bak"
    mv "$target" "$target.bak"
  fi
  ln -sf "$DOTFILES_DIR/config/claude/$f" "$target"
  echo "Linked claude $f -> $target"
done

# Claude hooks directory (symlink the whole dir so new hooks added to the
# repo show up automatically)
HOOKS_TARGET="$CLAUDE_DIR/hooks"
if [ -e "$HOOKS_TARGET" ] && [ ! -L "$HOOKS_TARGET" ]; then
  echo "Backing up existing $HOOKS_TARGET to $HOOKS_TARGET.bak"
  mv "$HOOKS_TARGET" "$HOOKS_TARGET.bak"
fi
ln -shf "$DOTFILES_DIR/config/claude/hooks" "$HOOKS_TARGET"
echo "Linked claude hooks -> $HOOKS_TARGET"

# Claude skills (symlink each tracked skill directory individually so users
# can still install other skills locally without them getting clobbered)
SKILLS_TARGET_DIR="$CLAUDE_DIR/skills"
mkdir -p "$SKILLS_TARGET_DIR"
for skill_dir in "$DOTFILES_DIR"/config/claude/skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_dir="${skill_dir%/}"
  skill_name=$(basename "$skill_dir")
  skill_target="$SKILLS_TARGET_DIR/$skill_name"
  if [ -e "$skill_target" ] && [ ! -L "$skill_target" ]; then
    echo "Backing up existing $skill_target to $skill_target.bak"
    mv "$skill_target" "$skill_target.bak"
  fi
  ln -shf "$skill_dir" "$skill_target"
  echo "Linked claude skill $skill_name -> $skill_target"
done

# Zsh aliases (sourced automatically by oh-my-zsh from $ZSH_CUSTOM)
ZSH_CUSTOM_DIR="$HOME/.oh-my-zsh/custom"
if [ -d "$ZSH_CUSTOM_DIR" ]; then
  ZSH_ALIASES_TARGET="$ZSH_CUSTOM_DIR/aliases.zsh"
  if [ -e "$ZSH_ALIASES_TARGET" ] && [ ! -L "$ZSH_ALIASES_TARGET" ]; then
    echo "Backing up existing $ZSH_ALIASES_TARGET to $ZSH_ALIASES_TARGET.bak"
    mv "$ZSH_ALIASES_TARGET" "$ZSH_ALIASES_TARGET.bak"
  fi
  ln -sf "$DOTFILES_DIR/config/zsh/aliases.zsh" "$ZSH_ALIASES_TARGET"
  echo "Linked zsh aliases -> $ZSH_ALIASES_TARGET"
else
  echo "Skipping zsh aliases: $ZSH_CUSTOM_DIR not found (install oh-my-zsh first)"
fi

# Fonts
FONTS_DIR="$HOME/Library/Fonts"
mkdir -p "$FONTS_DIR"
for font in "$DOTFILES_DIR"/fonts/*.ttf "$DOTFILES_DIR"/fonts/*.otf; do
  [ -e "$font" ] || continue
  cp -f "$font" "$FONTS_DIR/"
  echo "Installed font -> $FONTS_DIR/$(basename "$font")"
done

echo "Done."
