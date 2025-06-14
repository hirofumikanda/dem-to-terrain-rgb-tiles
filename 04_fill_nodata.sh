#!/bin/bash

INPUT_DIR="./data/output"
OUTPUT_DIR="./data/output_filled"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

for tif_file in "$INPUT_DIR"/*.tif; do
  echo "Processing $tif_file ..."
  base=$(basename "$tif_file" .tif)
  output_file="$OUTPUT_DIR/${base}.tif"

  python3 - <<EOF
import rasterio
import numpy as np

with rasterio.open("$tif_file") as src:
    profile = src.profile
    R = src.read(1)
    G = src.read(2)
    B = src.read(3)

# 例: 全バンドが0のピクセルを nodata とみなす（必要に応じて変更）
mask = (R == 0) & (G == 0) & (B == 0)

R[mask] = 1
G[mask] = 134
B[mask] = 160

profile.update({'nodata': None})

with rasterio.open("$output_file", "w", **profile) as dst:
    dst.write(R, 1)
    dst.write(G, 2)
    dst.write(B, 3)
EOF

  echo "→ Saved to $output_file"
done

echo "All files processed."
