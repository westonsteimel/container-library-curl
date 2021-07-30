#!/bin/bash

set -e

latest_stable_release=`curl --silent "https://api.github.com/repos/curl/curl/releases/latest" | jq .tag_name | xargs`
latest_stable_revision=`curl --silent "https://api.github.com/repos/curl/curl/commits/${latest_stable_release}" | jq .sha | xargs`
latest_stable_version=${latest_stable_release#"curl-"}
latest_stable_version=${latest_stable_version//_/.}

echo "latest stable version: ${latest_stable_version}, revision: ${latest_stable_revision}"

sed -ri \
    -e 's/^(ARG VERSION=).*/\1'"\"${latest_stable_version}\""'/' \
    -e 's/^(ARG REVISION=).*/\1'"\"${latest_stable_revision}\""'/' \
    "stable/Dockerfile"

git add stable/Dockerfile
git diff-index --quiet HEAD || git commit --message "updated stable to version ${latest_stable_version}, revision ${latest_stable_revision}"

edge_version="master"
edge_revision=`curl --silent "https://api.github.com/repos/curl/curl/commits/${edge_version}" | jq .sha | xargs`
echo "latest edge version: ${edge_version}, revision: ${edge_revision}"

sed -ri \
    -e 's/^(ARG VERSION=).*/\1'"\"${edge_version}\""'/' \
    -e 's/^(ARG REVISION=).*/\1'"\"${edge_revision}\""'/' \
    "edge/Dockerfile"

git add edge/Dockerfile
git diff-index --quiet HEAD || git commit --message "updated edge to version ${edge_version}, revision: ${edge_revision}"

