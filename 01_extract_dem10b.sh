#!/bin/bash

# 入力元と出力先のディレクトリを定義
SRC_DIR="./fgd"
DST_DIR="./data/input"

# 出力先ディレクトリを作成（存在しない場合）
mkdir -p "$DST_DIR"

# find で対象ZIPファイルを再帰的に検索し処理
find "$SRC_DIR" -type f -name "*DEM10B.zip" | while read -r zipfile; do
  echo "Extracting: $zipfile"
  
  # 一時作業用ディレクトリを作成
  tmpdir=$(mktemp -d)
  
  # 解凍
  unzip -q "$zipfile" -d "$tmpdir"
  
  # 解凍した中にある .xml ファイルを出力先にコピー
  find "$tmpdir" -type f -name "*.xml" -exec cp {} "$DST_DIR" \;
  
  # 一時ディレクトリを削除
  rm -rf "$tmpdir"
done

echo "完了しました。/data/input にDEM10BのXMLが配置されました。"
