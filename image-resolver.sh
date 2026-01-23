#!/usr/bin/env bash
set -euo pipefail

resolve_image() {
  local app="$1"
  local changed="$2"
  local registry="$3"
  local image_name="$4"
  # Use the current git commit SHA (Full) to match ${{ github.sha }}
  local commit_sha="$5"

  # SCENARIO 1: Source changed -> Use the Git SHA we just built
  if [[ "$changed" == "true" ]]; then
    echo "${registry}/${image_name}-${app}:sha-${commit_sha}"
    return
  fi

  # SCENARIO 2: No change -> Resolve 'latest' digest from registry
  # Suppress stderr to keep logs clean, unless it fails
  local digest
  digest=$(docker manifest inspect "${registry}/${image_name}-${app}:latest" 2>/dev/null | jq -r '.manifests[0].digest // .config.digest')

  if [[ -z "$digest" || "$digest" == "null" ]]; then
    echo "ERROR: Could not find 'latest' digest for ${app}. Is the image built?" >&2
    exit 1
  fi

  echo "${registry}/${image_name}-${app}@${digest}"
}