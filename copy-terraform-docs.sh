#!/bin/bash

SRC_DIR="modules"
DEST_DIR="docs/terraform/modules"

mkdir -p "$DEST_DIR"

find "$SRC_DIR" -type f -name "overview.md" | while read -r filepath; do
  rel_dir=$(dirname "${filepath#$SRC_DIR/}")
  mkdir -p "$DEST_DIR/$rel_dir"
  cp "$filepath" "$DEST_DIR/$rel_dir/overview.md"
  
  echo "Copied $filepath to $DEST_DIR/$rel_dir/overview.md"
done
