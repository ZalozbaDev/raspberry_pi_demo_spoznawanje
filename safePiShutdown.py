#!/usr/bin/python3 -u
# -*- coding:utf-8 -*-

from gpiozero import Button
import time
import os

# keys on EXP500 are at 5 6 13 19
# 5 and 19 are dangerous when the RESPEAKER is connected, only 6 and 13 can be used
# reserve 13 for shutdown and use 6 for the application (start/stop listening or similar)

stopButton = Button(13) # choose GPIO 13 from EXP500 == KEY2

while True:
     if stopButton.is_pressed:
        time.sleep(4) # wait for 4 seconds to avoid accidental presses
        if stopButton.is_pressed:
            os.system("shutdown now -h")
     time.sleep(1) # 1s wait is ok, user might have to press for up to 5s

# add this to "/etc/rc.local":
# sudo python3 /home/pi/safePiShutdown.py &

