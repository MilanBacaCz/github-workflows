#!/bin/bash
set -euo pipefail

# ─── Configuration ───
ORG_URL="${GITHUB_ORG_URL:?GITHUB_ORG_URL is required (e.g. https://github.com/MilanBacaCz)}"
RUNNER_TOKEN="${GITHUB_RUNNER_TOKEN:?GITHUB_RUNNER_TOKEN is required}"
RUNNER_NAME="${RUNNER_NAME:-local-runner}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted,linux,local}"
RUNNER_WORKDIR="${RUNNER_WORKDIR:-_work}"

# ─── Cleanup on exit ───
cleanup() {
  echo "Removing runner registration..."
  ./config.sh remove --token "${RUNNER_TOKEN}" 2>/dev/null || true
}
trap cleanup EXIT

# ─── Configure runner (org-level) ───
if [ ! -f ".runner" ]; then
  echo "Registering runner '${RUNNER_NAME}' for org ${ORG_URL}..."
  ./config.sh \
    --url "${ORG_URL}" \
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
