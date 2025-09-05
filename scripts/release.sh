#!/bin/bash
set -e

MODE=$1

if [ -z "$MODE" ]; then
  echo "Usage: $0 [prepare|publish|manifest <os>]"
  exit 1
fi

# Default organization if not set
ORG=${ORG:-"prestodb"}

# --- Get Version ---
POM_PATH="../pom.xml"
if [ ! -f "$POM_PATH" ]; then
  echo "Error: pom.xml not found in ../"
  exit 1
fi
VERSION=$(grep -m 1 '^    <version>' "$POM_PATH" | sed -e 's/.*<version>\([^<]*\)<\/version>.*/\1/' -e 's/-SNAPSHOT//')
echo "Version: $VERSION"

# --- Get Commit ID ---
COMMIT_ID=$(git -C .. rev-parse --short HEAD)
echo "Commit ID: $COMMIT_ID"

# --- Get Architecture ---
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
  ARCH="arm64"
fi
echo "Architecture: $ARCH"

# --- Define images to process ---
# List of (OLD_IMAGE, OS) tuples
IMAGES_TO_PROCESS=(
  "presto/presto-dev:ubuntu-22.04 ubuntu"
  "presto/presto-dev:centos9 centos"
)

for IMAGE_INFO in "${IMAGES_TO_PROCESS[@]}"; do
  read -r OLD_IMAGE OS <<<"$IMAGE_INFO"
  NEW_TAG="${ORG}/presto-dev:${VERSION}-${COMMIT_ID}-${OS}-${ARCH}"

  if [ "$MODE" = "prepare" ]; then
    echo "Tagging ${OLD_IMAGE} as ${NEW_TAG}"
    ${DOCKER_CMD:-docker} tag "${OLD_IMAGE}" "${NEW_TAG}" || echo "No image ${OLD_IMAGE}, skipping"
  elif [ "$MODE" = "publish" ]; then
    echo "Pushing ${NEW_TAG}"
    ${DOCKER_CMD:-docker} push "${NEW_TAG}" || echo "No image ${NEW_TAG}, skipping"
  fi
done

if [ "$MODE" = "manifest" ]; then
  TARGET_OS=$2 # centos or ubuntu
  echo "Creating multi-arch manifest for latest-${TARGET_OS}..."

  # Construct image names for amd64 and arm64
  AMD64_IMAGE="${ORG}/presto-dev:${VERSION}-${COMMIT_ID}-${TARGET_OS}-amd64"
  ARM64_IMAGE="${ORG}/presto-dev:${VERSION}-${COMMIT_ID}-${TARGET_OS}-arm64"
  LATEST_TAG="docker.io/${ORG}/presto-dev:latest-${TARGET_OS}"

  ${DOCKER_CMD:-docker} manifest create ${LATEST_TAG} ${AMD64_IMAGE} ${ARM64_IMAGE}
  ${DOCKER_CMD:-docker} manifest annotate ${LATEST_TAG} ${AMD64_IMAGE} --os linux --arch amd64
  ${DOCKER_CMD:-docker} manifest annotate ${LATEST_TAG} ${ARM64_IMAGE} --os linux --arch arm64
  ${DOCKER_CMD:-docker} manifest push ${LATEST_TAG}
fi

echo "Done."
