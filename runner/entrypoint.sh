#!/bin/bash
set -euo pipefail

# ─── Configuration ───
REPO_URL="${GITHUB_REPO_URL:?GITHUB_REPO_URL is required (e.g. https://github.com/MilanBacaCz/mediservis)}"
RUNNER_TOKEN="${GITHUB_RUNNER_TOKEN:?GITHUB_RUNNER_TOKEN is required}"
RUNNER_NAME="${RUNNER_NAME:-hetzner-runner}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted,linux,hetzner}"
RUNNER_WORKDIR="${RUNNER_WORKDIR:-_work}"

# ─── Cleanup on exit ───
cleanup() {
  echo "Removing runner registration..."
  ./config.sh remove --token "${RUNNER_TOKEN}" 2>/dev/null || true
}
trap cleanup EXIT

# ─── Configure runner ───
if [ ! -f ".runner" ]; then
  echo "Registering runner '${RUNNER_NAME}' for ${REPO_URL}..."
  ./config.sh \
    --url "${REPO_URL}" \
    --token "${RUNNER_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --labels "${RUNNER_LABELS}" \
    --work "${RUNNER_WORKDIR}" \
    --replace \
    --unattended
fi

# ─── Start runner ───
echo "Starting GitHub Actions runner..."
exec ./run.sh
