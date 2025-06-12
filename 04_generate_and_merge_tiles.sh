#!/bin/bash

INPUT_DIR="./data/output"
TMP_TILE_DIR="./data/tiles"
FINAL_TILE_DIR="./data/tiles_xyz"
ZOOM="0-14"
MERGED_TIF="./merged.tif"

# 作業ディレクトリ初期化
rm -rf "$TMP_TILE_DIR" "$FINAL_TILE_DIR" "$MERGED_TIF"
mkdir -p "$TMP_TILE_DIR" "$FINAL_TILE_DIR"

# 1. すべての .tif を1つにマージ
echo "🧩 Merging all TIFFs in $INPUT_DIR..."
gdal_merge.py -n -9999 -a_nodata -9999 -o "$MERGED_TIF" "$INPUT_DIR"/*.tif

# 2. タイル化（補間は gdal2tiles 側で行う）
echo "🧱 Generating tiles from merged TIFF..."
GDAL_PAM_ENABLED=NO gdal2tiles.py -z "$ZOOM" -r bilinear --resampling=bilinear "$MERGED_TIF" "$TMP_TILE_DIR"

echo "✅ 全タイルの変換が完了しました → $FINAL_TILE_DIR"
