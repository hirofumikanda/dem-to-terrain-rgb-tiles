import rasterio

with rasterio.open("merged.tif") as src:
    profile = src.profile
    R = src.read(1)
    G = src.read(2)
    B = src.read(3)

# nodata 判定（例: R==0 and G==0 and B==0 を nodataと仮定）
mask = (R == 0) & (G == 0) & (B == 0)

# nodata を 0m相当の RGB に置換
R[mask] = 1
G[mask] = 134
B[mask] = 160

# 出力
with rasterio.open("merged_nodata_filled.tif", "w", **profile) as dst:
    dst.write(R, 1)
    dst.write(G, 2)
    dst.write(B, 3)
