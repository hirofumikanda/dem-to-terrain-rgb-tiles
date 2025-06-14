#!/bin/bash

MERGED_TIF="./merged.tif"
TILE_DIR="./data/tiles"
ZOOM="0-14"

# 作業ディレクトリ初期化
rm -rf "$TILE_DIR"
mkdir -p "$TILE_DIR"

# タイル化（補間は gdal2tiles 側で行う）
echo "Generating tiles from merged TIFF..."
GDAL_PAM_ENABLED=NO gdal2tiles.py -z "$ZOOM" -r bilinear --resampling=bilinear "$MERGED_TIF" "$TILE_DIR"

echo "全タイルの変換が完了しました → $TILE_DIR"
