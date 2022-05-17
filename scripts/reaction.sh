#!/bin/bash

# check this before building container, USB output is dynamic
AUDIOOUTPUTDEVICE="alsa:device=hw=2.0"

# adjust to the IP assigned to delock-XXXX (check fritz.box web UI)
LIGHT_SOCKET_IP=192.168.188.35

# for HUE, find out the IP like described here: https://huetips.com/help/how-to-find-my-bridge-ip-address/ 
# https://discovery.meethue.com/
# and adjust ".hue.json" appropriately

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
			mplayer -ao $AUDIOOUTPUTDEVICE $(shuf -n1 -e njejsym_rozumil.mp3 prosu_hisce_raz.mp3)
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
		wget --timeout=5 --tries=1 -O -  http://${LIGHT_SOCKET_IP}/cm?cmnd=Power%20On
		;;
	_LIGHTOFF_*)
		echo "Switching light off"
		wget --timeout=5 --tries=1 -O -  http://${LIGHT_SOCKET_IP}/cm?cmnd=Power%20Off
		;;
	_SWEAR_*)
		echo "Don't swear!"
		# mplayer -ao $AUDIOOUTPUTDEVICE $(shuf -n1 -e a_poklate.mp3 nic_zelic.mp3)
		;;
	_SERBSCE_*)
		echo "Speak sorbian!"
		mplayer -ao $AUDIOOUTPUTDEVICE $(shuf -n1 -e rec_serbsce.mp3)
		;;
	_BRIGHTNESS_*_005_*)
		echo "Brightness command: $1"
		hue -c /dLabPro/bin.release/.hue.json lights 1 =10 
		;;
	_BRIGHTNESS_*_010_*)
		echo "Brightness command: $1"
		hue -c /dLabPro/bin.release/.hue.json lights 1 =20 
		;;
	_BRIGHTNESS_*_050_*)
		echo "Brightness command: $1"
		hue -c /dLabPro/bin.release/.hue.json lights 1 =100 
		;;
	_BRIGHTNESS_*_080_*)
		echo "Brightness command: $1"
		hue -c /dLabPro/bin.release/.hue.json lights 1 =160 
		;;
	_BRIGHTNESS_*_100_*)
		echo "Brightness command: $1"
		hue -c /dLabPro/bin.release/.hue.json lights 1 =200 
		;;
	_SETCOLOR_*_RED_*)
		echo "Setcolor command: $1"
		hue -c /dLabPro/bin.release/.hue.json lights 1 red 
		;;
	_SETCOLOR_*_GREEN_*)
		echo "Setcolor command: $1"
		hue -c /dLabPro/bin.release/.hue.json lights 1 green
		;;
	_SETCOLOR_*_BLUE_*)
		echo "Setcolor command: $1"
		hue -c /dLabPro/bin.release/.hue.json lights 1 blue
		;;
	_SNOOZE_*)
		echo "Waiting for wakeup key!"
		python3 ./snooze.py
		;;
	*)
		echo "$1 is unknown!"
		;;
	esac	
fi
