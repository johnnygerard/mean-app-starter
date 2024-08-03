#!/bin/bash
set -o errexit

# Init Angular client (CLI will prompt for SSR)
ng new --skip-git --skip-tests --directory=client --inline-style --style=css "${repo_name:?}"
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
npm pkg set scripts.vercel:build='ng version && ng build --configuration "$VERCEL_ENV"'

cd -
