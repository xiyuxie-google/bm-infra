#!/bin/bash

# === Usage ===
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 JOB_REFERENCE RUN_TYPE"
  exit 1
fi

JOB_REFERENCE="$1"
RUN_TYPE="$2"

echo "Querying records for JobReference LIKE '$JOB_REFERENCE%'..."

####
# blaze run -c opt //cloud/tpu/tools/c2xprof:main -- \
#   --alsologtostderr --gcs_path=gs://my-bucket/path/to/profile


# Fetch records from Spanner, now including JobReference and RecordId
RECORDS_JSON=$(gcloud spanner databases execute-sql "$GCP_DATABASE_ID" \
  --instance="$GCP_INSTANCE_ID" \
  --project="$GCP_PROJECT_ID" \
  --sql="SELECT JobReference, Model, Status, Device, RecordId FROM RunRecord WHERE JobReference='$JOB_REFERENCE' AND RunType='$RUN_TYPE';" \
  --format=json)

# Check if any records were found
RECORD_COUNT=$(echo "$RECORDS_JSON" | jq '.rows | length')

if [ "$RECORD_COUNT" -eq 0 ]; then
  echo "No matching records found for JobReference LIKE '$JOB_REFERENCE%'."
  exit 0
fi

echo "Found $RECORD_COUNT matching records:"
echo ""

# Print header
printf "%-25s %-30s %-15s %-15s %s\n" "JobReference" "Model" "Status" "Device" "Profile"
printf "%-25s %-30s %-15s %-15s %s\n" "-------------------------" "------------------------------" "---------------" "---------------" "------------------------------------------------------------------------------------------------"

# Parse JSON and print each row
echo "$RECORDS_JSON" | jq -c '.rows[]' | while read -r row; do
  JOB_REF=$(echo "$row" | jq -r '.[0]')
  MODEL=$(echo "$row" | jq -r '.[1]' | awk -F/ '{print $NF}')
  STATUS=$(echo "$row" | jq -r '.[2]')
  DEVICE=$(echo "$row" | jq -r '.[3]')
  RECORD_ID=$(echo "$row" | jq -r '.[4]')

  PROFILE_FOLDER="gs://$GCS_BUCKET/job_logs/$RECORD_ID/static_profile"

  printf "%-30s %-15s %-15s %s\n" "$MODEL" "$STATUS" "$DEVICE" "$PROFILE_FOLDER"
done
