#!/bin/bash

INPUT_DIR="./data/output_filled"
MERGED_TIF="./merged.tif"

# 作業ディレクトリ初期化
rm -f "$MERGED_TIF"

# すべての .tif を1つにマージ
echo "Merging all TIFFs in $INPUT_DIR..."
gdal_merge.py -o "$MERGED_TIF" "$INPUT_DIR"/*.tif
