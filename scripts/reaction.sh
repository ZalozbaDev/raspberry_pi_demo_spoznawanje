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
		wget --timeout=5 --tries=1 -O -  http://192.168.178.44/cm?cmnd=Power%20On
		;;
	_LIGHTOFF_*)
		echo "Switching light off"
		wget --timeout=5 --tries=1 -O -  http://192.168.178.44/cm?cmnd=Power%20Off
		;;
	_SWEAR_*)
		echo "Don't swear!"
		mplayer -ao alsa:device=hw=1.0 $(shuf -n1 -e a_poklate.mp3 nic_zelic.mp3)
		;;
	_SERBSCE_*)
		echo "Speak sorbian!"
		mplayer -ao alsa:device=hw=1.0 $(shuf -n1 -e rec_serbsce.mp3)
		;;
	_BRIGHTNESS_*)
		echo "Brightness command: $1"
		if (echo $1 | grep -q "<NUM>"); then
			PERCENT=$(echo $1 | sed -r 's/.*<NUM>(.*)<\/NUM>.*/\1/')
		else
			PERCENT=NONE
		fi
		echo "Percent=$PERCENT"
		if [ "$PERCENT" != "NONE" ]; then
			PERCENTVALUE=$(echo "$(($PERCENT))")"%"
		else
			PERCENTVALUE="no_value"
		fi
	
		echo "Value=${PERCENTVALUE}"
		
		# multiply by 2 and specify after "="
		# hue -c /dLabPro/bin.release/.hue.json lights 1 =10 
		;;
	_WAKEMEUP_*)
		echo "Wakemeup command: $1"
		;;
	_SETCOLOR_*_RED_*)
		echo "Setcolor command: $1"
		# hue -c /dLabPro/bin.release/.hue.json lights 1 red 
		;;
	_SETCOLOR_*_GREEN_*)
		echo "Setcolor command: $1"
		# hue -c /dLabPro/bin.release/.hue.json lights 1 green
		;;
	_SETCOLOR_*_BLUE_*)
		echo "Setcolor command: $1"
		# hue -c /dLabPro/bin.release/.hue.json lights 1 blue
		;;
	*)
		echo "$1 is unknown!"
		;;
	esac	
fi
