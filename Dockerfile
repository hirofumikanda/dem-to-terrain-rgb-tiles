FROM rust:1.80

# 必要なライブラリをインストール
RUN apt-get update && apt-get install -y \
    pkg-config libgdal-dev gdal-bin git \
 && rm -rf /var/lib/apt/lists/*

# ソースをクローンしてビルド
WORKDIR /app
RUN git clone https://github.com/nokonoko1203/japan-dem.git
WORKDIR /app/japan-dem
RUN cargo install --path .

# 実行用（例）
ENTRYPOINT ["japan-dem"]
