#!/bin/sh

REPO_DIR=$HOME/sites
SITE_DIR=repo
DEPLOY_DIR=/Eduardo/repo

cd $REPO_DIR/$SITE_DIR

# Check for repo update
if [ -n "$(git pull --ff-only | grep 'Already up to date.')" ]; then
	exit
fi
echo "Updating $SITE_DIR site"

# Build site
hugo 2>&1 >/dev/null

# sync new files across
rsync -a public/* $DEPLOY_DIR/

