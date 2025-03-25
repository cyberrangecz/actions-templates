#!/bin/bash

# Replace these values with your organization name and personal access token
ORG="cyberrangecz"               # Your GitHub organization name

# Define the branch settings
BRANCH_SETTINGS='{
  "delete_branch_on_merge": true
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

# Loop through each repository
for repo in $repos; do
    echo "Setting Automatically delete head branches at $ORG/$repo"

    # Apply the protection settings to the specified branch
    response=$(curl -s -o /dev/null -w "%{http_code}" -X PATCH \
        -H "Authorization: token $TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$ORG/$repo" \
        -d "$BRANCH_SETTINGS")

    if [ "$response" -eq 200 ]; then
        echo "Automatically delete head branches applied to $repo successfully."
    else
        echo "Failed to apply automatically delete head branches to $repo (HTTP status: $response)."
    fi
done
