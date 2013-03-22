#!/bin/sh

TIME="4:00am"
MAILTO="admin@server.com"
SUBJECT_TAG="[Server Maintenance]"
LISTID="List-Id: server-admin <admin@server.com>"

SCRIPT="/tmp/rebootScript.sh"

cat << EOT > $SCRIPT 
	#!/bin/sh

	echo "Server is shutting down as scheduled" | mail -s "$SUBJECT_TAG Administration tasks" -a $LISTID $MAILTO
	reboot

	// Auto-destroy this script
	rm -f $SCRIPT

	exit 0
EOT

echo "Server will reboot at $TIME" | mail -s "$SUBJECT_TAG Administrative task scheduled" -a $LISTID $MAILTO

at -v $TIME -f $SCRIPT
