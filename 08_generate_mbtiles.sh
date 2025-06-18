#!/bin/bash

TILE_DIR="./data/tiles"
MBTILES="./terrain.mbtiles"

rm -rf "$MBTILES"
mb-util --image_format=png --scheme="tms" "$TILE_DIR" "$MBTILES"

sqlite3 "$MBTILES" < ./metadata.sql
