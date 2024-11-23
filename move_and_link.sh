#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
mkdir -p "$DOTFILES_DIR"

if [ -z "$1" ]; then
    echo "Usage: $0 <absolute_or_relative_path_to_file_or_directory>"
    exit 1
fi

TARGET="$1"

if [ ! -e "$TARGET" ]; then
    echo "Error: '$TARGET' does not exist."
    exit 1
fi

ABS_PATH=$(realpath "$TARGET")
PARENT_DIR=$(dirname "$ABS_PATH")
BASENAME=$(basename "$TARGET")

mv "$ABS_PATH" "$DOTFILES_DIR/$BASENAME"

ln -s "$DOTFILES_DIR/$BASENAME" "$PARENT_DIR/$BASENAME"

echo "Moved" '$ABS_PATH' to '$DOTFILES_DIR' and created a symbolic link at '$PARENT_DIR/$BASENAME'
