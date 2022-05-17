#!/usr/bin/python3 -u
# -*- coding:utf-8 -*-

import RPi.GPIO as GPIO
import time
import os
import subprocess
import re

import apa102

import sys

# keys on EXP500 are at 5 6 13 19
# 5 and 19 are dangerous when the RESPEAKER is connected, only 6 and 13 can be used
# reserve 13 for shutdown and use 6 for the application (start/stop listening or similar)
KEY = [6]

# LEDs on EXP500 are at 26 12 16 20
# 20 is occupied when RESPEAKER is connected, so do not drive directly!
LED = [26,12,16]

POWER = 5

PIXELS_N = 12

ring = apa102.APA102(num_led=PIXELS_N)

GPIO.setmode(GPIO.BCM)

for i in KEY:
    print("Setting up GPIO " + str(i) + " to input/pullup.")
    GPIO.setup(i, GPIO.IN, GPIO.PUD_UP)

#define a easy way to set pin value
def ledWrite(pin,value):
        if value:
                GPIO.output(pin,GPIO.HIGH)
        else:
                GPIO.output(pin,GPIO.LOW)

def ringWrite(data):
        for i in range(PIXELS_N):
            ring.set_pixel(i, int(data[4*i + 1]), int(data[4*i + 2]), int(data[4*i + 3]))
        ring.show()
    
def ringSetPixel(data):
        ring.set_pixel(int(data[0]), int(data[1]), int(data[2]), int(data[3]))
        ring.show()

def ringRotate():
        ring.rotate()
        ring.show()
        
for i in LED:
        GPIO.setup(i,GPIO.OUT)
        print("Setting up LED " + str(i) + " to OFF.")
        ledWrite(i,0)
        
# enable ring power
GPIO.setup(POWER, GPIO.OUT)
GPIO.output(POWER, GPIO.HIGH)

outLED = GPIO.PWM(16,50)
outLED.start(0)
outLED.ChangeDutyCycle(0)
statusLED = GPIO.PWM(26,50)
statusLED.start(0)
statusLED.ChangeDutyCycle(0)

print ('Args: ', len(sys.argv))
print ('Arg 1:', sys.argv[1])

if (sys.argv[1] == "SLEEP"):
  ringWrite([0, 0, 0, 0] * PIXELS_N)
if (sys.argv[1] == "WAKEUP"):
  ringWrite([0, 0, 0, 24] * PIXELS_N)
if (sys.argv[1] == "1"):
  ringWrite([0, 0, 0, 24] * 10 + [0, 0, 0, 0] * 2)
if (sys.argv[1] == "2"):
  ringWrite([0, 0, 0, 24] * 8 + [0, 0, 0, 0] * 4)
if (sys.argv[1] == "3"):
  ringWrite([0, 0, 0, 24] * 6 + [0, 0, 0, 0] * 6)
if (sys.argv[1] == "4"):
  ringWrite([0, 0, 0, 24] * 4 + [0, 0, 0, 0] * 8)
if (sys.argv[1] == "5"):
  ringWrite([0, 0, 0, 24] * 2 + [0, 0, 0, 0] * 10)
