#!/bin/bash

# Replace these values with your organization name and personal access token
ORG="cyberrangecz"               # Your GitHub organization name

# Define the branch settings
BRANCH_SETTINGS='{
  "delete_branch_on_merge": true
}'

# Fetch all repositories in the organization
repos=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/orgs/$ORG/repos?per_page=100" | jq -r '.[].name')

# Loop through each repository and apply branch protection
for repo in $repos; do
    echo "Setting Automatically delete head branches at $ORG/$repo"

    # Apply the protection settings to the specified branch
    response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
        -H "Authorization: token $TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$ORG/$repo" \
        -d "$BRANCH_SETTINGS")

    if [ "$response" -eq 200 ]; then
        echo "Branch protection applied to $repo successfully."
    else
        echo "Failed to apply branch protection to $repo (HTTP status: $response)."
    fi
done
