#!/bin/bash

set -e

edge_version="master"
edge_revision=`curl --silent "https://api.github.com/repos/curl/curl/commits/${edge_version}" | jq .sha | xargs`
echo "latest edge version: ${edge_version}, revision: ${edge_revision}"

sed -ri \
    -e 's/^(ARG VERSION=).*/\1'"\"${edge_version}\""'/' \
    -e 's/^(ARG REVISION=).*/\1'"\"${edge_revision}\""'/' \
    "edge/Dockerfile"

git add edge/Dockerfile
git diff-index --quiet HEAD || git commit --message "updated edge to version ${edge_version}, revision: ${edge_revision}"

