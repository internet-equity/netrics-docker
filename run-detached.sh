#!/bin/sh

IMG_NAME=$1
DOCKERFILE_PATH=$2

docker build -t $IMG_NAME $DOCKERFILE_PATH
if [ $? -eq 0 ]; then
    echo "Build succeeded"
else
    echo "Build failed. Exiting"
    exit 1
fi
docker run --rm -i --name netrics-container -v ./volumes/netrics/result:/home/netrics/result $IMG_NAME