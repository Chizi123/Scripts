REPO_DIR=$HOME/sites
SITE_DIR=repo
DEPLOY_DIR=/Eduardo/repo

cd $REPO_DIR/$SITE_DIR

# Check for repo update
if [[ -n $(git pull | grep 'Already up to date.') ]]; then
#	exit
	echo 1
fi

# Build site
hugo

# sync new files across
rsync -av public/* $DEPLOY_DIR/

