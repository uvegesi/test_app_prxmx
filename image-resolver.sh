#!/usr/bin/env bash
set -euo pipefail

resolve_image() {
  local app="$1"
  local changed="$2"
  local registry="$3"
  local image_name="$4"
  local commit_sha="$5"

  # SCENARIO 1: Source changed -> Use the Git SHA we just built
  if [[ "$changed" == "true" ]]; then
    echo "${registry}/${image_name}-${app}:sha-${commit_sha}"
    return
  fi

  # Use 'docker buildx imagetools inspect' to get the distribution digest.
  # This works for both Single-Arch and Multi-Arch images reliably.
  
  local digest
  digest=$(docker buildx imagetools inspect \
    "${registry}/${image_name}-${app}:latest" \
    --format "{{.Manifest.Digest}}" 2>/dev/null)

  if [[ -z "$digest" ]]; then
    echo "ERROR: Could not find 'latest' digest for ${app}. Is the image built?" >&2
    exit 1
  fi

  echo "${registry}/${image_name}-${app}@${digest}"
}