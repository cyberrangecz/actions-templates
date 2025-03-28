#!/bin/bash

# Replace these values with your organization name and personal access token
ORG="cyberrangecz"               # Your GitHub organization name
BRANCH="develop"                  # Branch name to protect (e.g., "main" or "master")

# Define the branch protection settings
PROTECTION_SETTINGS='{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "required_signatures": true,
  "restrictions": null
}'

# Fetch all repositories in the organization
page=1

set -x
while true; do
    data=$(curl -s -H "Authorization: token $TOKEN" \
        "https://api.github.com/orgs/$ORG/repos?per_page=100&page=$page" | jq -r '.[].name')

    # Stop if no more repositories are found
    [[ -z "$data" ]] && break

    # Extract repository names
    repos+="$data "

    ((page++))
done

# Loop through each repository and apply branch protection
for repo in $repos; do
    echo "Setting branch protection on $ORG/$repo/$BRANCH"

    # Apply the protection settings to the specified branch
    response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
        -H "Authorization: token $TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$ORG/$repo/branches/$BRANCH/protection" \
        -d "$PROTECTION_SETTINGS")

    if [ "$response" -eq 200 ]; then
        echo "Branch protection applied to $repo successfully."
    else
        echo "Failed to apply branch protection to $repo (HTTP status: $response)."
    fi
done
