#!/bin/bash

echo "###################################"
echo "#          Server backup          #"
echo "###################################"
echo "Start: `date`"

RSYNC="/usr/bin/rsync"
LOG="/var/log/backupServer/"
CONFIGURATION_FILE="backupServer.conf"
DATE=`date "+%Y-%m-%dT%H:%M:%S"`

# Global options of rsync
RSYNC_OPTS="-azP \
--delete \
--delete-excluded \
--link-dest=../current"

###################################
# Initial requirements

# rsync is required!
if [ ! -x $RSYNC ]; then
	echo "Cannot find rsync: $RSYNC"
	exit
fi

# configuration file is required!
if [ ! -f $CONFIGURATION_FILE ]; then
	echo "Configuration file not found"
	exit
fi

# Load configuration file
. $CONFIGURATION_FILE
###################################
# Configuration file verifications

# Check source dir
if [ ! -d $SOURCE ]; then
	echo "Source must be a directory"
	exit
fi

# Check destination dir
if [ ! -d $TARGET ]; then
	echo "Destination must be a directory"
	exit
fi

# Exclude files if this is set
for ex in  $IGNORE_FILES; do
	EXCLUDE="$EXCLUDE --exclude=$ex"
done
RSYNC_OPTS="$RSYNC_OPTS $EXCLUDE"

# run rsync
echo "$RSYNC $RSYNC_OPTS $OPTIONS $SOURCE $TARGET"

echo "Backup successful!"
echo "End: `date`"
