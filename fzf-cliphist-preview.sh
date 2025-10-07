#!/bin/bash

selected=$1
tmpfile=$(mktemp /tmp/fzf-clip-preview-XXXXXX)
empty_image=$(mktemp /tmp/empty-image-XXXXXX.png)

# Create a transparent 1x1 pixel image to "clear" previous images
convert -size 1x1 xc:transparent "$empty_image" 2>/dev/null || {
  # Fallback: create a small black image if imagemagick is not available
  printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\rIDATx\x9cc\xf8\x0f\x00\x00\x01\x00\x01\x00\x18\xdd\x8d\xb4\x00\x00\x00\x00IEND\xaeB`\x82' >"$empty_image"
}

# Decode the cliphist content to a temporary file
cliphist decode "$selected" >"$tmpfile"

# Detect the MIME type of the content
mime_type=$(file --mime-type -b "$tmpfile")

if [[ "$mime_type" == image/* ]]; then
  # Clear previous images and display the actual image
  kitty +kitten icat --clear --transfer-mode=memory --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 "$tmpfile" 2>/dev/null
else
  # Show the content using bat, fallback to cat if bat fails
  bat --paging=never --style=plain "$tmpfile" || cat "$tmpfile"
  echo
  # Clear any previous image with an empty image at the end
  kitty +kitten icat --clear --transfer-mode=memory --stdin=no "$empty_image" 2>/dev/null
fi

# Cleanup temporary files
rm -f "$tmpfile" "$empty_image"
