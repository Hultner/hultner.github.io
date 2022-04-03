#!/usr/bin/env sh

# Build container with build args and create tags
docker build \
    -t hultner/hultner:latest -t hultner/hultner:"$1" \
    --build-arg GIT_COMMIT="$(git rev-parse --short HEAD)" \
    --build-arg VERSION="$1" .
