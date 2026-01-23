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

  # SCENARIO 2: No change -> Resolve 'latest' digest from registry
  
  # Fetch the inspection data...
  local raw_output
  raw_output=$(docker buildx imagetools inspect "${registry}/${image_name}-${app}:latest" 2>/dev/null)

  # ...and strictly filter for the line starting with "Digest:"
  local digest
  digest=$(echo "$raw_output" | grep "^Digest:" | awk '{print $2}')

  # Safety check: ensure we actually got a SHA
  if [[ -z "$digest" ]]; then
    echo "ERROR: Could not find 'latest' digest for ${app}." >&2
    exit 1
  fi

  echo "${registry}/${image_name}-${app}@${digest}"
}