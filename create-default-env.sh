#!/bin/bash

# Script to create default environment configuration
# Run from the root of your front-end project

# Define the target directory and file
ENV_DIR="lib"
ENV_FILE="$ENV_DIR/.env"

# Create the lib directory if it doesn't exist
if [ ! -d "$ENV_DIR" ]; then
  echo "Creating directory: $ENV_DIR"
  mkdir -p "$ENV_DIR"
fi

# Check if .env file already exists
if [ -f "$ENV_FILE" ]; then
  echo "Warning: $ENV_FILE already exists!"
  read -p "Do you want to overwrite it? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 1
  fi
fi

# Create the .env file with default configuration
cat >"$ENV_FILE" <<EOF
# Default Environment Configuration
# Generated on $(date)

USE_PRODUCTION_FIREBASE=false
USE_LOCAL_STORAGE=true
EOF

# Confirm creation
if [ $? -eq 0 ]; then
  echo "✓ Default environment configuration created at: $ENV_FILE"
  echo "Contents:"
  cat "$ENV_FILE"
else
  echo "✗ Error creating environment file"
  exit 1
fi
