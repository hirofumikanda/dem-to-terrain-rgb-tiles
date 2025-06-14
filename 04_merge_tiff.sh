#!/bin/bash

INPUT_DIR="./data/output"
MERGED_TIF="./merged.tif"

# 作業ディレクトリ初期化
rm -rf "$INPUT_DIR" "$MERGED_TIF"
mkdir -p "$INPUT_DIR"

# すべての .tif を1つにマージ
echo "Merging all TIFFs in $INPUT_DIR..."
gdal_merge.py -o "$MERGED_TIF" "$INPUT_DIR"/*.tif
