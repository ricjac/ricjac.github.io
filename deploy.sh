#!/bin/bash

if [[ -z $1 ]]; then
    echo "Commit message missing"
    exit 0
fi

echo "Deploying updates to Github"

# Build the project.
hugo

# Go To Public folder
cd public
# Add changes to git.
git add -A
# Commit changes.
git commit -m "$1"
# Push source and build repos.
git push origin master
# Come Back
cd ..


git add -A
git commit -m "$1"
git push origin hugo