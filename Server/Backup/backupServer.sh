#!/bin/bash -x
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
--hard-links \
--perms \
--times \
--quiet "

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

if [ $DIRECTION == "" ]; then
	echo "A direction is requiered!"
	exit 1
fi

if [ $DIRECTION == "R-L" ]; then RL=1; else RL=0; fi

# Check source dir
if [ $RL -eq 1 -a ! -d "$SOURCE" ]; then
	echo "Source must be a local directory"
	exit
fi

# Check destination dir
if [ $RL -eq 0 -a ! -d "$TARGET" ]; then
	echo "Destination must be local a directory"
	exit
fi

# If file exist create hardlinks to it
CURRENT="$TARGET/current"
#if [ -h $CURRENT ]; then
#	RSYNC_OPTS="$RSYNC_OPTS --link-dest=$CURRENT"
#fi
RSYNC_OPTS="$RSYNC_OPTS --link-dest=../current"

if [ $RL -eq 0 ]; then
	DESTINATION="$HOST:$TARGET/$DATE/"
	ORIGIN="$SOURCE"
else
	ORIGIN="$HOST:$SOURCE"
	DESTINATION="$TARGET/$DATE/"
fi

# Exclude files if this is set
for ex in  $IGNORE_FILES; do
	EXCLUDE="$EXCLUDE --exclude=$ex"
done

RSYNC_OPTS="$RSYNC_OPTS $EXCLUDE $OPTIONS"

# run rsync
$RSYNC $RSYNC_OPTS $ORIGIN $DESTINATION

# Point link to last backup
if [ $RL -eq 1 ]; then
	if [ -h $CURRENT ]; then
		unlink $CURRENT
	fi
	ln -s $DATE $CURRENT
else
	ssh $HOST \
	"unlink $CURRENT; \ 
	ln -s $DATE $CURRENT"
fi

echo "Backup successful!"
echo "End: `date`"
