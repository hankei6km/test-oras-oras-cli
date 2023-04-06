#!/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORAS_CLI="${HOME}/.local/bin/oras"

USER="${GITHUB_ACTOR}"
#REPONAME="${GITHUB_REPOSITORY##*/}"

REGISTRY="ghcr.io"
REGISTRY_CONFIG="$(mktemp)"
trap 'test -f "${REGISTRY_CONFIG}" && rm -f "${REGISTRY_CONFIG}"' EXIT

PACKAGE="${1}"

envsubst < "${BASE_DIR}/envsubst_token.txt" | "${ORAS_CLI}" login "${REGISTRY}" --username "${USER}" --password-stdin --registry-config "${REGISTRY_CONFIG}"

cp "${BASE_DIR}/../README.md" "${BASE_DIR}/README.md"
cd "${BASE_DIR}"
"${ORAS_CLI}" push \
    "${REGISTRY}/${GITHUB_REPOSITORY}/${PACKAGE}:latest" \
    "README.md:application/markdown" \
    --annotation-file <(envsubst '${GITHUB_REPOSITORY}' < "${BASE_DIR}/envsubst_annotation.txt") \
    --registry-config "${REGISTRY_CONFIG}"
rm "${BASE_DIR}/README.md"