#!/bin/bash
set -o errexit

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

cd -
