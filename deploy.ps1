param (
	[string]$msg = "Rebuilding site"
)

Write-Host "Deploying updates to Github"

# Build the project.
hugo

# Go To Public folder
cd public
# Add changes to git.
git add -A
# Commit changes.
git commit -m "$msg"
# Push source and build repos.
git push origin master
# Come Back
cd ..


git add -A
git commit -m "$msg"
git push origin hugo
