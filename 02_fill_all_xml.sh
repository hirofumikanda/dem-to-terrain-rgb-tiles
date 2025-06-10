#!/bin/bash

INPUT_DIR="./data/input"

# XML ファイルをすべて処理
find "$INPUT_DIR" -type f -name "*.xml" | while read -r xmlfile; do
  echo "処理中: $xmlfile"
  python3 fill_dem_tuples.py "$xmlfile" "$xmlfile"
done

echo "✅ すべてのXMLに fill_dem_tuples.py を適用しました。"
