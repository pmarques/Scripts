#!/bin/bash

HOST="127.0.0.1"
PORT=50000

function Connect() {
	ret=1
	while [ ! $ret == 0 ]; do
		exec 3<>/dev/tcp/$HOST/$PORT 2>&1 >> /dev/null
		ret=$?
		sleep 1;
	done
}

Connect

while [ 1 ]; do
	ip=`curl -s http://automation.whatismyip.com/n09230945.asp`
	echo -e "$ip" >&3
	ret=$?
	if [  ! $ret == 0 ]; then
		echo "Reconnect..."
		Connect
	fi
	sleep 1; 
done
