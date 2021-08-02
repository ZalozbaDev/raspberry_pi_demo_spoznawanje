#!/usr/bin/python3 -u
# -*- coding:utf-8 -*-

from gpiozero import Button
import time
import os

stopButton = Button(13) # choose GPIO 13 from EXP500 == KEY2

while True:
     if stopButton.is_pressed:
        time.sleep(4) # wait for 4 seconds to avoid accidental presses
        if stopButton.is_pressed:
            os.system("shutdown now -h")
     time.sleep(1) # 1s wait is ok, user might have to press for up to 5s

