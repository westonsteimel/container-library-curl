#!/bin/sh

VERSION=$(grep -e "ARG CURL_VERSION=" stable/Dockerfile)
VERSION=${VERSION#ARG CURL_VERSION=\"}
VERSION=${VERSION%\"}
echo "Tagging version ${VERSION}"
docker tag "${DOCKER_USERNAME}/curl:latest" "${DOCKER_USERNAME}/curl:${VERSION}"
