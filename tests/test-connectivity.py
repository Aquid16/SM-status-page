import requests
import os
import sys

# List of paths to test
paths = [
    "/",
    "/dashboard/",
    "/dashboard/components/",
    "/dashboard/components/groups/",
    "/dashboard/incidents/",
    "/dashboard/maintenances/",
    "/dashboard/subscribers/",
    "/dashboard/metrics/",
    "/dashboard/user/profile/",
]

# Base URL
BASE_URL = "https://test.sm-status-page.com"

# Check environment variables
USERNAME = os.getenv("USERNAME")
PASSWORD = os.getenv("PASSWORD")
if not USERNAME or not PASSWORD:
    print("Error: USERNAME and PASSWORD environment variables must be set")
    sys.exit(1)

# Create a Session instance to save cookies
session = requests.Session()

# Log in to the server
login_url = f"{BASE_URL}/dashboard/login/"  # Adjust the path to your login page
response = session.post(login_url, data={"username": USERNAME, "password": PASSWORD})

if response.status_code != 200:
    print(f"Login failed with status code {response.status_code}")
    sys.exit(1)

# Variable to count failures
failures = 0

# Loop to test each path
for path in paths:
    url = BASE_URL + path
    print(f"Testing {url}...")
    
    try:
        # Send GET request with the session (including the cookie)
        response = session.get(url, timeout=10)
        status_code = response.status_code
        response_body = response.text
        
        print(f"Response body: {response_body}")
        print(f"Status code: {status_code}")
        
        if status_code in [200, 301, 302]:
            print(f"✓ Success: {url} returned {status_code}")
        else:
            print(f"✗ Failure: {url} returned {status_code} (expected 200, 301, or 302)")
            failures += 1
    except requests.exceptions.RequestException as e:
        print(f"✗ Failure: {url} failed with error: {e}")
        failures += 1

# Summary of results
if failures == 0:
    print("All tests passed successfully!")
    sys.exit(0)
else:
    print(f"{failures} tests failed.")
    sys.exit(1)
