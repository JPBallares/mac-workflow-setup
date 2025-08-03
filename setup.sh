#!/bin/bash

# Path to your dotfiles repo
CONFIG_DIR="$HOME/.dev/configs"

# List of files to symlink (source relative to DOTFILES_DIR, target relative to $HOME)
declare -A FILES=(
  [".vimrc"]="$CONFIG_DIR/vimrc"
  [".tmux.conf"]="$CONFIG_DIR/tmux.conf"
  [".config/nvim/init.lua"]="$CONFIG_DIR/nvim/init.lua"
  [".config/gitui/key_bindings.ron"]="$CONFIG_DIR/gitui/key_bindings.ron"
)

# Create symlinks
for TARGET in "${!FILES[@]}"; do
  SRC="${FILES[$TARGET]}"
  DEST="$HOME/$TARGET"
  DEST_DIR=$(dirname "$DEST")
  mkdir -p "$DEST_DIR"
  ln -sf "$SRC" "$DEST"
  echo "Linked $SRC -> $DEST"
done

