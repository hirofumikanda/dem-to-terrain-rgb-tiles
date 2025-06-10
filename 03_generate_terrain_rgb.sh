#!/bin/bash

docker run --rm -v $(pwd)/data:/data japan-dem /data/input/ --output /data/output/ --terrain-rgb
# docker run --rm -v $(pwd)/data:/data japan-dem /data/input/FG-GML-6544-42-dem10b-20161001.xml --output /data/output/ --terrain-rgb
# docker run --rm -v $(pwd)/data:/data japan-dem /data/input/FG-GML-6040-62-dem10b-20161001.xml --output /data/output/ --terrain-rgb
