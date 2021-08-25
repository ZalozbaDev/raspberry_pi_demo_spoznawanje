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
	_LIGHTON_*)
		echo "Switching light on"
		wget -O -  http://192.168.188.35/cm?cmnd=Power%20On
		;;
	_LIGHTOFF_*)
		echo "Switching light off"
		wget -O -  http://192.168.188.35/cm?cmnd=Power%20Off
		;;
	_SWEAR_*)
		echo "Don't swear!"
		mplayer -ao alsa:device=hw=1.0 $(shuf -n1 -e a_poklate.mp3 nic_zelic.mp3)
		;;
	_SERBSCE_*)
		echo "Speak sorbian!"
		mplayer -ao alsa:device=hw=1.0 $(shuf -n1 -e rec_serbsce.mp3)
		;;
	*)
		echo "$1 is unknown!"
		;;
	esac	
fi
