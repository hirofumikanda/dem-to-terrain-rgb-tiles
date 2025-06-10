#!/bin/bash

INPUT_DIR="./data/output"
TMP_TILE_DIR="./tmp_tiles"
FINAL_TILE_DIR="./data/tiles"
ZOOM="0-14"

# 作業ディレクトリ初期化
rm -rf "$TMP_TILE_DIR" "$FINAL_TILE_DIR"
mkdir -p "$TMP_TILE_DIR" "$FINAL_TILE_DIR"

# 1. 各tifファイルをタイル化して一時出力
for tif_file in "$INPUT_DIR"/*.tif; do
  echo "Tiling $tif_file..."
  base=$(basename "$tif_file" .tif)
  gdal2tiles.py -z "$ZOOM" -r bilinear --resampling=bilinear "$tif_file" "$TMP_TILE_DIR/$base"
  # gdal2tiles.py -z "$ZOOM" -r near --resampling=near "$tif_file" "$TMP_TILE_DIR/$base"
done

# 2. タイルを走査してマージ（進捗表示付き）
echo "Merging all tiles into a single flat set..."

# 全タイル数をカウント
mapfile -t TILE_LIST < <(find "$TMP_TILE_DIR" -type f -name "*.png")
TOTAL=${#TILE_LIST[@]}
COUNT=0

for tile in "${TILE_LIST[@]}"; do
  ((COUNT++))
  printf "[%4d/%4d] %s\n" "$COUNT" "$TOTAL" "$tile"

  # terrain_rgb/以下の相対パス（z/x/y.png）に変換
  rel_path="$(echo "$tile" | sed -E 's|^.*/[^/]+_terrain_rgb/||')"

  # TMS → XYZ 変換
  z=$(echo "$rel_path" | cut -d'/' -f1)
  x=$(echo "$rel_path" | cut -d'/' -f2)
  y_tms=$(basename "$rel_path" .png)
  y_xyz=$(( (1 << z) - 1 - y_tms ))
  rel_path="$z/$x/$y_xyz.png"

  final_path="$FINAL_TILE_DIR/$rel_path"
  mkdir -p "$(dirname "$final_path")"

  if [ -f "$final_path" ]; then
    composite -compose over "$tile" "$final_path" "$final_path"
  else
    cp "$tile" "$final_path"
  fi
done

echo "✅ 全タイルの集約が完了しました → $FINAL_TILE_DIR"


echo "✅ 全タイルが $FINAL_TILE_DIR に集約・マージされました。"
