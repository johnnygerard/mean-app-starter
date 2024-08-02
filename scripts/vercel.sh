#!/bin/bash
set -o errexit

# Make sure the repository name is set
if [ -z "$repo_name" ]; then
  >&2 echo 'Error: undefined repository name variable'
  exit 1
fi

# Prompt for the Vercel token
read -rsp 'Provide a valid Vercel token: ' VERCEL_TOKEN
echo

# Prompt for the Vercel organization ID
read -rsp 'Provide your Vercel ID: ' VERCEL_ORG_ID
echo

# Create a new Vercel project and store secrets in GitHub repository
curl --request POST "https://api.vercel.com/v10/projects" \
  --header "Authorization: Bearer ${VERCEL_TOKEN}" \
  --header 'Content-Type: application/json' \
  --data "{\"name\":\"${repo_name}\"}" \
  | jq --raw-output '.id' \
  | gh secret set VERCEL_PROJECT_ID

gh secret set VERCEL_ORG_ID --body "$VERCEL_ORG_ID"
gh secret set VERCEL_TOKEN --body "$VERCEL_TOKEN"
