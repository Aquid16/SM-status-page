#!/bin/bash

# List of subpaths to test
paths=(
  "/"
  "/dashboard/"
  "/dashboard/components/"
  "/dashboard/components/groups/"
  "/dashboard/incidents/"
  "/dashboard/maintenances/"
  "/dashboard/subscribers/"
  "/dashboard/metrics/"
  "/dashboard/user/profile/"
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
  RESPONSE=$(curl -s -u "$USERNAME:$PASSWORD" --max-time 10 -w "%{http_code}" "$BASE_URL$path" -o response.txt)
  STATUS_CODE=${RESPONSE: -3}  # Extract the last 3 characters (HTTP code)
  
  echo "Response body: $(cat response.txt)"
  echo "Status code: $STATUS_CODE"
  
  if [ "$STATUS_CODE" -eq 200 ] || [ "$STATUS_CODE" -eq 301 ] || [ "$STATUS_CODE" -eq 302 ]; then
    echo "✓ Success: $BASE_URL$path returned $STATUS_CODE"
  else
    echo "✗ Failure: $BASE_URL$path returned $STATUS_CODE (expected 200, 301, or 302)"
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
