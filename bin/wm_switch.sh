#!/bin/sh

# Global variables
name_flag=''

# Methods
yabai() {
  echo "Killing all instances of Spectacle...\n"
  pkill all /Applications/Spectacle.app

  brew services start yabai
  brew services start skhd
  brew services start spacebar
}

spectacle() {
  echo "Stopping yabai, skhd, and spacebar...\n"
  brew services stop yabai
  brew services stop skhd
  brew services stop spacebar

  open /Applications/Spectacle.app
}

print_usage() {
  echo "Changing window manager to $name_flag \n"

  if [ "$name_flag" == "yabai" ]; then
    yabai
  else
    spectacle
  fi

  echo "\nFinished switching window managers! 🎉"
}

while getopts n: flag; do
  case "${flag}" in
    n) name_flag=${OPTARG};;
  esac
done

print_usage

