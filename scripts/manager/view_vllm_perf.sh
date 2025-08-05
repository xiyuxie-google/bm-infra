#!/bin/bash

# === view_vllm_perf.sh ===
# Description:
#   Fetches a vLLM log from GCS using a RecordId and parses it
#   to display performance statistics.
#
# Input:
#   $1: The RecordId of the job.
#
# Dependencies:
#   - 'gsutil' (from Google Cloud SDK) must be installed and authenticated.
#   - The 'get-vllm-perf' parser script must be in the same directory.
#

set -euo pipefail # Exit on error, undefined variable, or pipe failure
GCS_BUCKET="vllm-cb-storage2"

# --- Pre-flight Checks ---

# 1. Check if an argument is provided
if [ -z "${1-}" ]; then
    echo "Error: No RecordId provided." >&2
    echo "Usage: $0 <RecordId>" >&2
    exit 1
fi

# 2. Check for the gsutil command
if ! command -v gsutil &> /dev/null; then
    echo "Error: 'gsutil' command not found. Please install and configure the Google Cloud SDK." >&2
    exit 1
fi

# 3. Locate the parser script.
PARSER_SCRIPT_PATH="./scripts/agent/get_vllm_perf.sh"

if [ ! -x "$PARSER_SCRIPT_PATH" ]; then
    echo "Error: Parser script not found or not executable at '${PARSER_SCRIPT_PATH}'" >&2
    exit 1
fi

# --- Main Logic ---

RECORD_ID="$1"
GCS_PATH="gs://$GCS_BUCKET/job_logs/${RECORD_ID}/static_vllm_log.txt"

echo "➡️  Fetching and parsing performance log from:"
echo "   ${GCS_PATH}"
echo # Add a newline for cleaner output

# Use gsutil cat to stream the log file from GCS and pipe it to the parser.
# If gsutil fails (e.g., file not found), the script will exit due to "set -e".
gsutil cat "${GCS_PATH}" | "${PARSER_SCRIPT_PATH}"