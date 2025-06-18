#!/bin/bash

TILE_DIR="./data/tiles"
REPLACE_COLOR="rgb(1,134,160)"

find "$TILE_DIR" -type f -name "*.png" | while read -r png_file; do
    echo "Processing $png_file"

    convert "$png_file" \
        -background "$REPLACE_COLOR" -alpha remove -alpha off \
        -fill "$REPLACE_COLOR" -opaque "rgb(0,0,0)" \
        "$png_file"

done

echo "All tiles processed."
