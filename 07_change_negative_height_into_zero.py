import os
import glob
from PIL import Image, UnidentifiedImageError
import numpy as np

# 設定
REPLACE_COLOR = (1, 134, 160)  # RGB色
REPLACE_COLOR_ARRAY = np.array(REPLACE_COLOR, dtype=np.uint8)

# 対象ディレクトリ
TILE_DIR = "./data/tiles"

# 全PNGタイル取得
png_files = glob.glob(os.path.join(TILE_DIR, "*", "*", "*.png"))

print(f"Found {len(png_files)} tiles")

# 1枚ずつ処理
for png_file in png_files:
    print(f"Processing {png_file}")

    try:
        img = Image.open(png_file).convert("RGB")
    except UnidentifiedImageError:
        print(f"Skipped (Unidentified image): {png_file}")
        continue

    img_np = np.array(img).astype(np.uint32)

    R = img_np[:, :, 0]
    G = img_np[:, :, 1]
    B = img_np[:, :, 2]

    elevation = (R * 256 * 256 + G * 256 + B) * 0.1 - 10000
    mask = elevation < 0

    output_np = img_np.copy()
    output_np[mask] = REPLACE_COLOR_ARRAY

    output_img = Image.fromarray(output_np.astype(np.uint8), mode="RGB")
    output_img.save(png_file)

print("All tiles processed.")
