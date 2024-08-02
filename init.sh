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

### START CLIENT SETUP ########################################################
# Init Angular client (CLI will prompt for SSR)
ng new --skip-git --skip-tests --directory=client --inline-style --style=css "$repo_name"
cd client

# Remove redundant directories and files
rm -r .vscode/
rm .gitignore .editorconfig README.md

# Configure Angular project
ng config "projects.${repo_name}.schematics.@schematics/angular:component.displayBlock" true
ng config "projects.${repo_name}.schematics.@schematics/angular:component.changeDetection" OnPush

# Generate and configure Angular environments
ng generate environments

# Overwrite development environment
cat > src/environments/environment.development.ts << EOF
export const environment = {
  apiUrl: "http://localhost:3000",
  production: false,
};
EOF

# Overwrite production environment
cat > src/environments/environment.ts << EOF
export const environment = {
  production: true,
};
EOF

# Add preview environment
cat > src/environments/environment.preview.ts << EOF
export const environment = {
  production: false,
};
EOF

# Add preview Angular configuration
ng config "projects.${repo_name}.architect.build.configurations.preview" \
  '{"fileReplacements":[{"replace":"src/environments/environment.ts","with":"src/environments/environment.preview.ts"}]}'

# Install Tailwind CSS
npm install --save-dev tailwindcss postcss autoprefixer

# Add Tailwind CSS configuration
cat > tailwind.config.ts << EOF
import type { Config } from "tailwindcss";

export default {
  content: ["./src/**/*.{html,ts}"],
  theme: {
    extend: {},
  },
  plugins: [],
} satisfies Config;
EOF

# Reset global styles with Tailwind CSS
cat > src/styles.css << EOF
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

# Reset root component template
cat > src/app/app.component.html << EOF
<p>Deployment successful!</p>
<router-outlet />
EOF

# Add Vercel deployment npm script
# shellcheck disable=SC2016
npm pkg set scripts.vercel:build='ng version && ng build --configuration \"$VERCEL_ENV\"'

cd "$script_dir"
### END CLIENT SETUP ##########################################################

### START SERVER SETUP ########################################################
cd server

# Add environment file
touch .env

# Install TypeScript with Node.js v20 configuration
npm install --save-dev typescript @types/node@20 @tsconfig/node20

# Install Express
npm install express
npm install --save-dev @types/express

# Install CORS middleware
npm install cors
npm install --save-dev @types/cors

cd "$script_dir"
### END SERVER SETUP ##########################################################

# Reformat code with Prettier
npm run format

# Commit changes
git add .
git commit -m 'chore: initialize project'
git push

# Create Vercel project
source scripts/vercel.sh

echo 'Project initialized successfully!'
