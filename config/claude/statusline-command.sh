#!/usr/bin/env bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')
dirname=$(basename "$cwd")

# ANSI colors (same as robbyrussell theme)
GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[0;36m'
BLUE='\033[1;34m'
RED_DIM='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'
WHITE_DIM='\033[2;37m'

# Get git branch and dirty state from cwd
branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  dirty=$(git -C "$cwd" status --porcelain 2>/dev/null)
  if [ -n "$dirty" ]; then
    git_part="${BLUE}git:(${RED_DIM}${branch}${BLUE}) ${YELLOW}✗"
  else
    git_part="${BLUE}git:(${RED_DIM}${branch}${BLUE})"
  fi
else
  git_part=""
fi

# Context window usage — pre-calculated by Claude Code, null until first API call.
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  if [ "$used_int" -ge 80 ]; then
    ctx_color="$RED"
  elif [ "$used_int" -ge 50 ]; then
    ctx_color="$YELLOW"
  else
    ctx_color="$WHITE_DIM"
  fi
  ctx_part="${ctx_color}ctx:${used_int}%"
else
  ctx_part=""
fi

if [ -n "$git_part" ] && [ -n "$ctx_part" ]; then
  printf "${GREEN}➜${RESET}  ${CYAN}%s${RESET} %b${RESET} %b${RESET}\n" "$dirname" "$git_part" "$ctx_part"
elif [ -n "$git_part" ]; then
  printf "${GREEN}➜${RESET}  ${CYAN}%s${RESET} %b${RESET}\n" "$dirname" "$git_part"
elif [ -n "$ctx_part" ]; then
  printf "${GREEN}➜${RESET}  ${CYAN}%s${RESET} %b${RESET}\n" "$dirname" "$ctx_part"
else
  printf "${GREEN}➜${RESET}  ${CYAN}%s${RESET}\n" "$dirname"
fi
