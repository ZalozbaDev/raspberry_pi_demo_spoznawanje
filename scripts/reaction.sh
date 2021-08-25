#!/bin/bash

if [ "$#" -lt 1 ]; then 
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
	__REJECTED__)
		case $2 in 
		0)
			echo "Reject reaction for sleep state"
			;;
		*)
			echo "Reject reaction for active states"
			mplayer -ao alsa:device=hw=1.0 $(shuf -n1 -e njejsym_rozumil.mp3 prosu_hisce_raz.mp3)
			;;
	    esac
		;;
	__COUNTDOWN__)
		case $2 in 
		0)
			echo "Count down starting"
			;;
		[1-5])
			echo "Count down $2"
			python3 ./ring_status.py $2
			;;
		*)
			echo "Count down > 5"
			;;
	    esac
		;;
	_TELLTIME_*)
		echo "Telltime reaction"
		node slp.js
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
