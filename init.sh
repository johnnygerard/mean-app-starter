#!/bin/bash
set -o errexit

if [ ! -f package.json ] || [ "$(npm pkg get name)" != '"ng-express-template"' ]; then
  >&2 echo 'Error: Invalid execution path'
  >&2 echo 'This script must be executed from its parent directory.'
  exit 1
fi

# Prompt for repository name
read -rp 'Enter repository name: ' repo_name

# Validate repository name with regex
if [[ ! "$repo_name" =~ ^[a-z]+(-[a-z]+)*$ ]]; then
  >&2 echo 'Error: Invalid repository name'
  >&2 echo 'Use kebab-case (e.g. hello-world)'
  exit 1
fi

# Install Prettier with Tailwind CSS plugin
npm install --save-dev --save-exact prettier prettier-plugin-tailwindcss

# Install ESLint with TypeScript support
npm install --save-dev eslint @eslint/js @types/eslint__js typescript typescript-eslint

### START CLIENT SETUP ########################################################
# Init Angular client (CLI will prompt for SSR)
ng new --skip-git --skip-tests --directory=client --inline-style --style=css "$repo_name"
cd client

# Configure Angular project
ng config "projects.${repo_name}.schematics.@schematics/angular:component.displayBlock" true
ng config "projects.${repo_name}.schematics.@schematics/angular:component.changeDetection"

# Add Angular environments
ng generate environments

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

cd -
### END CLIENT SETUP ##########################################################

### START SERVER SETUP ########################################################
cd server

# Install TypeScript with Node.js v20 configuration
npm install --save-dev typescript @types/node@20 @tsconfig/node20

# Install Express
npm install express
npm install --save-dev @types/express

# Install CORS middleware
npm install cors
npm install --save-dev @types/cors

cd -
### END SERVER SETUP ##########################################################

# Commit changes
git add .
git commit -m 'build: initialize project'
