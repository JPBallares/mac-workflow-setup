#!/bin/bash

# Path to your dotfiles repo
CONFIG_DIR="$HOME/.dev/configs"

# Array of source:target pairs
FILES=(
  "$CONFIG_DIR/.vimrc:.vimrc"
  "$CONFIG_DIR/.tmux.conf:.tmux.conf"
  "$CONFIG_DIR/nvim/init.lua:.config/nvim/init.lua"
  "$CONFIG_DIR/gitui/key_bindings.ron:.config/gitui/key_bindings.ron"
  "$CONFIG_DIR/.tmux/utils/tsm:.tmux/utils/tsm"
)

# Create symlinks
for FILE_PAIR in "${FILES[@]}"; do
  SRC="${FILE_PAIR%:*}"
  TARGET="${FILE_PAIR#*:}"
  DEST="$HOME/$TARGET"
  DEST_DIR=$(dirname "$DEST")
  mkdir -p "$DEST_DIR"
  ln -sf "$SRC" "$DEST"
  echo "Linked $SRC -> $DEST"
done

