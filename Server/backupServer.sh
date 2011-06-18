#!/bin/bash
#
# Created by Patrick F. Marques 
# patrickfmarques AT gmail DOT com
#

echo "###################################"
echo "#          Server backup          #"
echo "###################################"
echo "Start: `date`"

RSYNC="/usr/bin/rsync"
LOG="/var/log/backupServer/"
CONFIGURATION_FILE="backupServer.conf"
DATE=`date "+%Y-%m-%dT%H:%M:%S"`

# Global options of rsync
RSYNC_OPTS="\
--archive \
--compress \
--partial \
--progress \
--delete \
--delete-excluded \
--hard-links"

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
#if [ ! -d $TARGET ]; then
#	echo "Destination must be a directory"
#	exit
#fi

# If file exist create hardlinks to it
CURRENT="$TARGET/current"
#if [ -h $CURRENT ]; then
#	RSYNC_OPTS="$RSYNC_OPTS --link-dest=$CURRENT"
#fi
RSYNC_OPTS="$RSYNC_OPTS --link-dest=../current"

DESTINATION="$HOST:$TARGET/$DATE/"

# Exclude files if this is set
for ex in  $IGNORE_FILES; do
	EXCLUDE="$EXCLUDE --exclude=$ex"
done

RSYNC_OPTS="$RSYNC_OPTS $EXCLUDE $OPTIONS"

# run rsync
$RSYNC $RSYNC_OPTS $SOURCE $DESTINATION

# Point link to last backup
#if [ -h $CURRENT ]; then
#	unlink $CURRENT
#fi
#ln -s $DATE $CURRENT
ssh $HOST \
"unlink $CURRENT; \ 
ln -s $DATE $CURRENT"

echo "Backup successful!"
echo "End: `date`"
