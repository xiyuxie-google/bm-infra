#!/bin/bash

# A script to taint multiple Terraform resources listed in a text file.
# Usage: ./taint_from_file.sh <path_to_file>
# Example: ./taint_from_file.sh ~/taint.txt

set -euo pipefail # Exit on error

# Check if a file path was provided
if [ -z "${1-}" ]; then
  echo "Error: No file path provided." >&2
  echo "Usage: $0 <path_to_file>" >&2
  exit 1
fi

RESOURCE_FILE="$1"

# Check that the file actually exists
if [ ! -f "$RESOURCE_FILE" ]; then
  echo "Error: File not found at '$RESOURCE_FILE'" >&2
  exit 1
fi

echo "➡️  Reading resources from '$RESOURCE_FILE'..."
echo

# Loop through each line of the input file
while IFS= read -r resource || [[ -n "$resource" ]]; do
  # Skip empty lines
  if [ -z "$resource" ]; then
    continue
  fi

  echo "-------------------------------------"
  echo "⚙️  Tainting resource: $resource"
  terraform taint "$resource"
done < "$RESOURCE_FILE"

echo
echo "✅  Finished processing all resources."