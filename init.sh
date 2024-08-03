#!/bin/bash
set -o errexit

# Set current working directory to script directory
script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir"

# Amend initial commit message
git commit --amend --message 'chore: clone template repository'
git push --force

# Enable GitHub workflows
mkdir .github
mv workflows .github

# Get repository name from current directory
repo_name="$(basename "$(realpath .)")"

# Update WebStorm settings
repo_name="$repo_name" perl -i -pe 's/mean-app-starter/$ENV{repo_name}/g' .idea/modules.xml
mv .idea/mean-app-starter.iml ".idea/${repo_name}.iml"

# Perform in-place text substitutions
perl -i -pe "s/2024/$(date +%Y)/" LICENSE.txt
perl -i -pe "s/¤REPO_NAME¤/${repo_name}/" vercel.json

# Install Prettier with Tailwind CSS plugin
npm install --save-dev --save-exact prettier prettier-plugin-tailwindcss

# Install ESLint with TypeScript support
npm install --save-dev eslint @eslint/js @types/eslint__js typescript typescript-eslint

# Create and set up Angular client
source scripts/client.sh

# Initialize Express server
source scripts/server.sh

# Reformat code with Prettier
npm run format

# Commit changes
git add .
git commit -m 'chore: initialize project'
git push

# Create Vercel project
source scripts/vercel.sh

echo 'Project initialized successfully!'
