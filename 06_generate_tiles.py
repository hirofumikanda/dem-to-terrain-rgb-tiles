import os
import numpy as np
import rasterio
from rasterio.enums import Resampling
import subprocess
from PIL import Image
from osgeo import gdal
import math
import mercantile
from rasterio.windows import from_bounds
from rasterio.enums import Resampling
from rasterio.errors import RasterioIOError
from rasterio.warp import transform as transform_coords

# ========= 設定 =========
INPUT_TIF = "data/merge/merged.tif"
DECODED_TIF = "data/intermediate/decoded_elevation.tif"
WARPED_TIF = "data/intermediate/warped_elevation.tif"
OUTPUT_DIR = "data/tiles"
ZOOM_MIN = 0
ZOOM_MAX = 14
TILE_SIZE = 256
# ========================

def decode_rgb_to_elevation(rgb_array):
    r = rgb_array[0].astype(np.uint32)
    g = rgb_array[1].astype(np.uint32)
    b = rgb_array[2].astype(np.uint32)
    elevation = (r * 256 * 256 + g * 256 + b) * 0.1 - 10000
    return elevation.astype(np.float32)

def convert_tif_to_elevation_tif():
    with rasterio.open(INPUT_TIF) as src:
        rgb = src.read([1, 2, 3])
        profile = src.profile.copy()
        elevation = decode_rgb_to_elevation(rgb)
        profile.update(dtype=rasterio.float32, count=1)
        os.makedirs(os.path.dirname(DECODED_TIF), exist_ok=True)
        with rasterio.open(DECODED_TIF, "w", **profile) as dst:
            dst.write(elevation, 1)

def warp_elevation_tif():
    os.makedirs(os.path.dirname(WARPED_TIF), exist_ok=True)
    subprocess.run([
        "gdalwarp",
        "-t_srs", "EPSG:3857",
        "-r", "bilinear",
        DECODED_TIF,
        WARPED_TIF
    ], check=True)

def encode_terrainrgb(elevation):
    value = np.clip((elevation + 10000) * 10, 0, 2**24 - 1).astype(np.uint32)
    r = (value >> 16) & 255
    g = (value >> 8) & 255
    b = value & 255
    return np.stack((r, g, b), axis=-1).astype(np.uint8)

def tile_bounds_mercator(z, x, y):
    tile = mercantile.xy_bounds(x, y, z)
    return tile.left, tile.bottom, tile.right, tile.top

def generate_tiles():
    with rasterio.open(WARPED_TIF) as src:
        # EPSG:3857 → EPSG:4326 に変換して mercantile に渡す
        min_lon, min_lat = transform_coords("EPSG:3857", "EPSG:4326", [src.bounds.left], [src.bounds.bottom])
        max_lon, max_lat = transform_coords("EPSG:3857", "EPSG:4326", [src.bounds.right], [src.bounds.top])

        for z in range(ZOOM_MIN, ZOOM_MAX + 1):
            x_min, y_max = mercantile.tile(min_lon[0], max_lat[0], z)[:2]
            x_max, y_min = mercantile.tile(max_lon[0], min_lat[0], z)[:2]

            print(f"[INFO] z={z} x: {x_min}-{x_max}, y: {y_min}-{y_max}")

            for x in range(x_min, x_max + 1):
                for y in range(y_max, y_min + 1):  # 上から下へ
                    left, bottom, right, top = tile_bounds_mercator(z, x, y)

                    try:
                        window = from_bounds(left, bottom, right, top, transform=src.transform)

                        elevation = src.read(
                            1,
                            window=window,
                            out_shape=(TILE_SIZE, TILE_SIZE),
                            resampling=Resampling.bilinear,
                            boundless=True,
                            fill_value=0.0
                        )

                        elevation = np.nan_to_num(elevation, nan=0.0)
                        if src.nodata is not None:
                            elevation[elevation == src.nodata] = 0.0

                    except Exception as e:
                        print(f"[WARN] z={z} x={x} y={y}: {e}")
                        elevation = np.zeros((TILE_SIZE, TILE_SIZE), dtype=np.float32)

                    rgb = encode_terrainrgb(elevation)
                    out_path = os.path.join(OUTPUT_DIR, str(z), str(x))
                    os.makedirs(out_path, exist_ok=True)
                    Image.fromarray(rgb, "RGB").save(f"{out_path}/{y}.png")

# ========= 実行 =========
convert_tif_to_elevation_tif()
warp_elevation_tif()
generate_tiles()
print("✅ 全処理完了しました")
