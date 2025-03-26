#!/bin/bash

# List of subpaths to test
paths=(
  "/"
  "/dashboard/"
  "/dashboard/components/"
  "/dashboard/extras/"
  "/dashboard/incidents/"
  "/dashboard/maintenances/"
  "/dashboard/subscribers/"
  "/dashboard/user/"
)

# Base domain
BASE_URL="https://test.sm-status-page.com"

# Check if environment variables are set
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
  echo "Error: USERNAME and PASSWORD environment variables must be set"
  exit 1
fi

# Variable to count failures
FAILURES=0

# Loop to test each path
for path in "${paths[@]}"; do
  echo "Testing $BASE_URL$path..."
  STATUS_CODE=$(curl -s -u "$USERNAME:$PASSWORD" -w "%{http_code}" -o /dev/null "$BASE_URL$path")
  if [ "$STATUS_CODE" -eq 200 ]; then
    echo "✓ Success: $BASE_URL$path returned 200"
  else
    echo "✗ Failure: $BASE_URL$path returned $STATUS_CODE (expected 200)"
    FAILURES=$((FAILURES + 1))
  fi
done

# Summary of results
if [ "$FAILURES" -eq 0 ]; then
  echo "All tests passed successfully!"
  exit 0
else
  echo "$FAILURES tests failed."
  exit 1
fi
