#!/bin/bash

if [ "$#" -ne 1 ]; then 
	echo "Invalid nr of cmdline args!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
else
	echo "Reacting to $1"
	case $1 in
	__WAKEUP__)
		echo "Wakeup reaction"
		python3 ./ring_status.py WAKEUP
		;;
	__SLEEP__)
		echo "Sleep reaction"
		python3 ./ring_status.py SLEEP
		;;
	_TELLTIME_*)
		echo "Telltime reaction"
		;;
	*)
		echo "$1 is unknown!"
		;;
	esac	
fi
