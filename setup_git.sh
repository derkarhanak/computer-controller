#!/bin/bash

# Initialize Git
echo "Initializing Git repository..."
git init

# Add all files (respecting .gitignore)
echo "Adding files..."
git add .

# Commit
echo "Committing initial version..."
git commit -m "Initial commit: Computer Controller for Linux"

# Ask for Remote URL
echo ""
echo "Please create a new repository on GitHub (https://github.com/new)."
echo "Enter the remote repository URL (e.g., https://github.com/yourname/repo.git):"
read REMOTE_URL

if [ -z "$REMOTE_URL" ]; then
  echo "No URL provided. skipping push."
  echo "You can push later using: git remote add origin <URL> && git push -u origin main"
  exit 1
fi

# Rename branch to main
git branch -M main

# Add Remote
git remote add origin "$REMOTE_URL"

# Push
echo "Pushing to GitHub..."
git push -u origin main

echo "Done!"
