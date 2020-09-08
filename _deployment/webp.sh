#!/bin/bash
# converting PNG images
find $1 -type f -and -iname "*.png" | while read png_path; do
    webp_path=${png_path/%.png/.webp}
    if [ ! -f "$webp_path" ]; then
	cwebp -quiet -preset icon "$png_path" -o "$webp_path"
    fi
done
