#!/usr/bin/env bash

# Folder containg the svn mirror
GIT_SYNC_DIR='/home/Repositories/GitSync'
# The name of remote where the repository is stored
GIT_K2C_REMOTE="k2c"

PROJECTS=$(ls -1 $GIT_SYNC_DIR)

echo $BASE
echo $PROJECTS
for PROJECT in $PROJECTS ; do
	P=$GIT_SYNC_DIR/$PROJECT
	if [ -d $P ] ; then
		echo "Project: $P"
		pushd $P
		echo "$ pwd=$(pwd)"
		echo "PWD=$PWD"
		# GIT_BASE="--git-dir=$P/.git --work-tree=$P"
		if [ -d $P/.git/svn ]; then
			git $GIT_BASE svn rebase trunk
		else
			git $GIT_BASE pull
		fi
		git $GIT_BASE push $GIT_K2C_REMOTE
		popd
	fi
done
