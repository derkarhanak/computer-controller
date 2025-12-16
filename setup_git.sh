#!/bin/bash

# Initialize Git if not already
if [ -d ".git" ]; then
    echo "Git already initialized."
else
    echo "Initializing Git repository..."
    git init
fi

# Add all files
echo "Adding files..."
git add .

# Commit (allow empty if nothing changed)
echo "Committing..."
git commit -m "Update from Computer Controller" || echo "Nothing to commit, continuing..."

git branch -M main

# Remote Setup
echo ""
echo "Enter the remote repository URL (leave empty to use existing origin if set):"
read INPUT_URL

if [ -n "$INPUT_URL" ]; then
    if git remote get-url origin > /dev/null 2>&1; then
        echo "Updating existing remote 'origin' to $INPUT_URL"
        git remote set-url origin "$INPUT_URL"
    else
        echo "Adding remote 'origin'..."
        git remote add origin "$INPUT_URL"
    fi
fi

# Check if remote is configured
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "Error: No remote repository configured. Please run script again and provide a URL."
    exit 1
fi

# Push with Force (to sync local state to new remote)
echo "Pushing to GitHub (using --force to ensure local version overwrites remote)..."
echo "NOTE: If you are asked for a password and it fails, you likely need a Personal Access Token (PAT)."
echo "      See: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens"
echo ""

git push -u origin main --force

echo "Done!"
