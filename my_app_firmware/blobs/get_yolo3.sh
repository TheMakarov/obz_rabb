#!/bin/bash

# File URL for YOLOv3 weights
YOLO_URL="https://pjreddie.com/media/files/yolov3.weights"

WEIGHTS_FILE="./yolov3.weights"

mkdir -p $DOWNLOAD_DIR

if [ -f "$WEIGHTS_FILE" ]; then
    echo "yolov3.weights already downloaded."
else
    echo "Downloading yolov3.weights..."
    wget -O "$WEIGHTS_FILE" "$YOLO_URL"

    if [ $? -eq 0 ]; then
        echo "Downloaded yolov3.weights successfully."
    else
        echo "Failed to download yolov3.weights."
        exit 1
    fi
fi
