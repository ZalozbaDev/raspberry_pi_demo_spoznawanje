#!/usr/bin/python3 -u
# -*- coding:utf-8 -*-

from gpiozero import Button
import time
import os

# keys on EXP500 are at 5 6 13 19
# 5 and 19 are dangerous when the RESPEAKER is connected, only 6 and 13 can be used
# reserve 13 for shutdown and use 6 for the application (start/stop listening or similar)

wakeupButton = Button(6) # choose GPIO 6 from EXP500 == KEY1

leaveLoop = False

while leaveLoop == False:
     if wakeupButton.is_pressed:
        time.sleep(1) # wait for 1 seconds to avoid accidental presses
        if wakeupButton.is_pressed:
            print("WAKING UP AGAIN!!!")
            leaveLoop = True
     print("ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ")
     time.sleep(1) # 1s wait is ok

